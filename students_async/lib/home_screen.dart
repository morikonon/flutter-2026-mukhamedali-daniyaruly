import 'package:flutter/material.dart';

import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Students')),
    body: ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.build_outlined),
          title: const Text('By hand'),
          subtitle: const Text('Four states with three fields'),
          onTap: () => _open(context, const StudentsScreen()),
        ),
        ListTile(
          leading: const Icon(Icons.hourglass_bottom),
          title: const Text('FutureBuilder'),
          subtitle: const Text(
            'The Future is a field, the Switch does not reload',
          ),
          onTap: () => _open(context, const StudentsFutureScreen()),
        ),
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: const Text('Countdown'),
          subtitle: const Text('A Stream: StreamBuilder or listen + cancel'),
          onTap: () => _open(context, const CountdownScreen()),
        ),
      ],
    ),
  );
}
