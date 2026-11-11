import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

/// One countdown, two ways to listen to it.
class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _versionB = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Countdown')),
    body: Column(
      children: [
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('A: StreamBuilder')),
            ButtonSegment(value: true, label: Text('B: listen')),
          ],
          selected: {_versionB},
          onSelectionChanged: (value) =>
              setState(() => _versionB = value.first),
        ),
        Expanded(
          child: Center(
            child: _versionB ? const _ListenVersion() : const _BuilderVersion(),
          ),
        ),
      ],
    ),
  );
}

/// Version A: StreamBuilder listens and cancels by itself.
class _BuilderVersion extends StatefulWidget {
  const _BuilderVersion();

  @override
  State<_BuilderVersion> createState() => _BuilderVersionState();
}

class _BuilderVersionState extends State<_BuilderVersion> {
  // A field, like the Future in Level 3: build must not start a new stream.
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
    stream: _stream,
    builder: (context, snapshot) => _BigNumber(snapshot.data ?? 10),
  );
}

/// Version B: we listen ourselves, so we must cancel ourselves.
class _ListenVersion extends StatefulWidget {
  const _ListenVersion();

  @override
  State<_ListenVersion> createState() => _ListenVersionState();
}

class _ListenVersionState extends State<_ListenVersion> {
  int _left = 10;
  late final StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    // Without this the stream keeps ticking for a screen that is gone.
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _BigNumber(_left);
}

class _BigNumber extends StatelessWidget {
  const _BigNumber(this.value);

  final int value;

  @override
  Widget build(BuildContext context) =>
      Text('$value', style: Theme.of(context).textTheme.displayLarge);
}
