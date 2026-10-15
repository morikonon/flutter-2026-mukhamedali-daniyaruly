import 'package:flutter/material.dart';

import 'routes.dart';
import 'students.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Root of the stack: canPop() is false, so AppBar draws no arrow.
      appBar: AppBar(title: const Text('Students')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, i) {
          final s = students[i];
          return ListTile(
            leading: CircleAvatar(child: Text(s.name[0])),
            title: Text(s.name),
            subtitle: Text(s.group),
            trailing: const Icon(Icons.chevron_right),
            // Only the route name is known here, not the DetailScreen class.
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.student, arguments: s),
          );
        },
      ),
    );
  }
}
