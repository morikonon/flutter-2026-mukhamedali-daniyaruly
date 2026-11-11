import 'package:flutter/foundation.dart';

class Student {
  const Student({required this.name, required this.group, this.gpa});

  final String name;
  final String group;
  final double? gpa;
}

class NoConnectionException implements Exception {}

const _seed = [
  Student(name: 'Aida Nurlanova', group: 'IT-2301', gpa: 3.7),
  Student(name: 'Dias Seitkali', group: 'IT-2301', gpa: 3.1),
  Student(name: 'Aruzhan Bek', group: 'IT-2302'),
  Student(name: 'Timur Alibekov', group: 'IT-2302', gpa: 2.9),
  Student(name: 'Dana Omarova', group: 'IT-2303', gpa: 3.9),
  Student(name: 'Alikhan Kairatuly', group: 'IT-2303', gpa: 3.4),
];

/// The API that does not exist yet: slow like a network, and sometimes down.
class FakeApi {
  FakeApi({this.empty = false});

  final bool empty; // true -> the server has no students
  int calls = 0; // how many times fetchStudents() ran
  int _saves = 0;

  // async: the caller gets a Future right away, the list comes later.
  Future<List<Student>> fetchStudents() async {
    // Remembered before await: other calls may bump `calls` while we wait.
    final call = ++calls;
    debugPrint('fetchStudents #$call');
    // await waits without blocking: the app keeps drawing meanwhile.
    await Future.delayed(const Duration(seconds: 2));
    // A throw inside async completes the Future with this error.
    if (call % 3 == 0) throw NoConnectionException();
    return empty ? const [] : _seed;
  }

  Future<void> save(int value) async {
    final call = ++_saves;
    await Future.delayed(const Duration(seconds: 1));
    if (call.isEven) throw StateError('server rejected $value');
  }
}
