# Notes — The Data Arrives Later

Everything below was run with `flutter run -d chrome` (no Xcode on this Mac).
The widget-level checks were also repeated with `flutter test`.

## Level 1 — a fake API and the order of events

**Predicted:** `A`, `C`, the first frame, and two seconds later `B` and
`6 students`. `main()` does not wait for the timer or for the Future; it runs
to the end, the loop draws the screen, and the two callbacks come later as
events.

**Actual** (seconds since `A`):

```
A
C
fetchStudents #1
first frame        +0.37 s
B                  +2.00 s
6 students         +2.00 s
```

(`first frame` comes from a `addPostFrameCallback` print added only for the
experiment.)

**Three calls in a row:** `#1 #2 #3`, two lines `6 students`, and then
`DartError: Instance of 'NoConnectionException'`. The app keeps running. On
Chrome the unhandled error is printed as `DartError: …`; on Android or desktop
Flutter prints the same error as `Unhandled Exception: …`.

**A bug this run found.** The first version read `calls` after the `await`:
`if (calls % 3 == 0)`. With three calls in a row all three failed, because by
the time each of them woke up `calls` was already 3. The fix keeps the number
in a local before the `await`: `final call = ++calls;`. The line after `await`
runs later, and a field may have changed by then.

**`sleep` instead of `await`.** On Chrome `sleep` from `dart:io` throws
`Unsupported operation: ProcessUtils._sleep`: a browser has no sleep. A busy
loop of two seconds does the same job:

```
A
C
fetchStudents #1
6 students         +2.00 s
first frame        +2.39 s
B                  +2.55 s
```

The first frame came two seconds late, and even the timer `B` that was due at
2 s came after it. The loop was blocked, not waiting.

## Level 2 — four states by hand

Visit 1 and visit 2 show the list, visit 3 shows the error view, Retry shows
the list (call #4). The fake server is a `static` field of the screen, so its
counters survive Back.

Back during the two seconds, with the guards: the console stays clean.
Without both `if (!mounted) return;` lines:

```
setState() called after dispose(): _StudentsScreenState#3937a(lifecycle state: defunct, not mounted)
```

## Level 3 — FutureBuilder

**Ten flips of the Switch:** the console shows one `fetchStudents #1`, and the
list never flickers.

**`future: _api.fetchStudents()` inline in build:** every flip shows a spinner
and the console counts `#2 #3 #4 #5 #6` — one request per rebuild. Requests #3
and #6 end on the error view.

**Server down** (`fetchStudents` always throws): with `hasError` first the
error view and Retry appear. With `if (!snapshot.hasData) return LoadingView()`
first the spinner never stops, because a failed request has no data.

## Level 4 — a countdown, two ways

**Version B with `cancel()`:** Back at 7, the console stops at `tick 7`.

**Version B without `cancel()`:** Back at 7, and the ticks go on to 0. After
every tick:

```
tick 6
setState() called after dispose(): _ListenVersionState#39208(lifecycle state: defunct, not mounted)
tick 5
setState() called after dispose(): _ListenVersionState#39208(lifecycle state: defunct, not mounted)
…
tick 0
setState() called after dispose(): _ListenVersionState#39208(lifecycle state: defunct, not mounted)
```

The same error as Level 2, a different messenger. Nobody is on screen, and
the stream keeps working. That is the leak.

**Version A:** there is no `cancel()` anywhere in our code, Back at 7, and the
console stops at `tick 7`. `StreamBuilder` cancels its subscription in its own
`dispose`.

## Level 5 — errors that do not vanish

**The AI version:** `onPressed: () { _api.save(n); Navigator.pop(context); }`.
`flutter analyze` says **No issues found!**: `unawaited_futures` only checks
`async` bodies, and this callback is not `async`. Once the callback is marked
`async`, the same line is flagged:

```
Missing an 'await' for the 'Future' computed by this expression. Try adding an 'await' or wrapping the expression with 'unawaited' • unawaited_futures
```

Saved twice: both times the screen closes as if it worked, and after the
second one the console says `DartError: Bad state: server rejected 6`.
**The user saw a success.**

**The honest version:** `await` inside `try / on StateError`,
`context.mounted` after the `await`. The first save closes the screen. The
second shows the SnackBar `server rejected 6`, and the screen stays. While the
save runs, the button shows a spinner and is disabled. Two fast taps send one
request.
