import 'package:flutter/material.dart';

import 'routes.dart';
import 'students.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.student});

  final Student student;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Local copy: the screen can change it without touching the list.
  late Student _student = widget.student;

  Future<void> _edit() async {
    // pushNamed<String> makes the result String? instead of Object?.
    final name = await Navigator.of(context)
        .pushNamed<String>(Routes.edit, arguments: _student);
    // null = user pressed back; !mounted = this screen is already gone.
    if (name == null || !mounted) return;
    setState(() => _student = _student.copyWith(name: name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _edit,
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.school),
            title: Text(_student.group),
            subtitle: const Text('Group'),
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: Text(_student.email),
            subtitle: const Text('Email'),
          ),
        ],
      ),
    );
  }
}
