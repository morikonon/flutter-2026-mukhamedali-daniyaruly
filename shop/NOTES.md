# Notes — Put It High, Subscribe Low

## Level 1 — lifted

**Total in the badge, the honest way.** `total` travels from `Shell` to
`CartBadge`: **2 constructors** touched (`BooksScreen`, `CartBadge`) in
**3 files** — `main.dart` (the owner computes it), `books_screen.dart` (takes it
only to hand it on), `cart_badge.dart` (finally shows it). `BooksScreen` never
uses `total`; it is a courier.

**One tap on Add prints 7 lines:** `BooksScreen build` plus `row …` for all
6 books. `setState` in `Shell` marks everything below it dirty, so five rows
that did not change are rebuilt anyway.

## Level 2 — a model with no widgets

`Cart` runs before `runApp`: add, add, add the first again, remove →
`1 items, 3100 ₸`. `cart.items.add(...)` from outside throws
`Unsupported operation: Cannot add to an unmodifiable list` — only `add` can
change the cart, and `add` always notifies. Same checks live in
`test/cart_test.dart`.

## Level 3 — the same app with provider

`grep -r "cart:" lib/` finds nothing: no widget between the provider and the
badge knows the cart exists.

**The loud one** — `context.watch<Cart>().add(b)` in `onPressed`, on tap:

```
Tried to listen to a value exposed with provider, from outside of the widget tree.

This is likely caused by an event handler (like a button's onPressed) that called
Provider.of without passing `listen: false`.

To fix, write:
Provider.of<Cart>(context, listen: false);
```

**The silent one** — `context.read<Cart>().count` in the badge's `build`: no
error, no warning. Two books show *Added*, the badge still says **0** — nobody
said "I depend on the cart", so nobody rebuilds it.

## Level 4 — scope

Counted from the `debugPrint` lines. Two books in the cart, Cart screen open,
**+** pressed three times, then one book removed:

| Badge subscribes with                         | 3 × **+** | remove |
| --------------------------------------------- | --------- | ------ |
| `context.watch<Cart>().count`                 | **3** badge builds | 1 |
| `context.select<Cart, int>((c) => c.count)`   | **0** badge builds | 1 |

Same model, same taps, one line changed in one widget: the count did not
change, so with `select` the badge does not rebuild.

**Watch moved up on purpose** — `context.watch<Cart>()` at the top of
`BooksScreen.build`: three **+** on the Cart screen give 3 `BooksScreen build`
and **18** `row …` lines on a screen nobody is looking at. The badge stays at 0
only because it is `const CartBadge()`. Subscribe where the value is shown, not
where it is convenient.

## Level 5 — where does it live?

| Value | Home | Why |
| --- | --- | --- |
| The cart | **provided** | Both routes and the badge read it, several widgets change it: one `ChangeNotifierProvider` above `MaterialApp`, each reader subscribes where it shows it. |
| Search text in the Books AppBar | **ephemeral** | Only the Books screen reads and writes it; `_query` in `_BooksScreenState`, gone with the screen. |
| Cart total expanded / collapsed | **ephemeral** | A visual toggle of one widget on one screen — a `bool` in that widget's `State`. |
| Theme mode (dark-mode switch) | **lifted** | Only `MaterialApp` reads it and one switch writes it: a `State` above `MaterialApp`, like `Shell` in Level 1. |

The model never decides UI: `add` returns a `bool` and the row shows the
SnackBar; the Cart screen asks in a dialog and only then calls `clear()`.
`models/` imports only `foundation.dart`.
