import 'package:flutter/foundation.dart';

// async* returns a Stream: not one value later, but many values over time.
Stream<int> countdown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    yield i; // hands one value to the listener
    debugPrint('tick $i');
  }
}
