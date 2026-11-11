import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

/// Four states by hand: loading, error, empty, data.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  // static: one fake server for every visit, so its counters survive Back
  // and the second Save (the one that fails) is reachable.
  static final _api = FakeApi();
  List<Student>? _students; // null = not loaded yet
  Object? _error; // not null = the request failed
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // initState cannot be async: start the request, do not wait for it.
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      // The line after await runs 2 s later: the screen may be closed by then.
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _save(BuildContext context) async {
    if (_saving) return; // a second fast tap must not send a second request
    setState(() => _saving = true);
    try {
      await _api.save(_students!.length);
      if (!context.mounted) return;
      Navigator.pop(context); // only on success
    } on StateError catch (e) {
      if (!context.mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Widget _buildBody() {
    final students = _students;
    if (_error != null) return ErrorView(onRetry: _load);
    if (students == null) return const LoadingView();
    if (students.isEmpty) return const EmptyView();
    return StudentList(students);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('By hand')),
    body: _buildBody(),
    // Nothing to save until the list is here.
    floatingActionButton: _students == null
        ? null
        : FloatingActionButton(
            tooltip: 'Save',
            onPressed: _saving ? null : () => _save(context),
            child: _saving
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
  );
}
