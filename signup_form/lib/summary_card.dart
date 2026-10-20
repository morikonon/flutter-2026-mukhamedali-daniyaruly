import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
  });

  final String name;
  final String email;
  final String group;
  final String birthDate;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ListTile(
        leading: const Icon(Icons.person),
        title: Text(name),
        subtitle: const Text('Name'),
      ),
      ListTile(
        leading: const Icon(Icons.mail),
        title: Text(email),
        subtitle: const Text('Email'),
      ),
      ListTile(
        leading: const Icon(Icons.group),
        title: Text(group),
        subtitle: const Text('Group'),
      ),
      ListTile(
        leading: const Icon(Icons.cake),
        title: Text(birthDate),
        subtitle: const Text('Date of birth'),
      ),
    ];
    return Card(
      // Decides by the space it is given, not by the screen size.
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 600
            ? GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: 4,
                physics: const NeverScrollableScrollPhysics(),
                children: tiles,
              )
            : Column(mainAxisSize: MainAxisSize.min, children: tiles),
      ),
    );
  }
}
