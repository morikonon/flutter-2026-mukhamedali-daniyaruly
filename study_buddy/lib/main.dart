import 'package:flutter/material.dart';

import 'data/seed.dart';
import 'models/session.dart';
import 'tabs/list_tab.dart';

// The only literal colour in lib/: every other colour comes from the scheme.
const seedColor = Colors.indigo;

void main() => runApp(const MyApp());

/// Temporary for step 2: holds the sessions until the shell takes over.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Session> _sessions = seedItems();

  void _toggleFavourite(Session session) => setState(() {
    _sessions = _sessions
        .map(
          (s) =>
              s.id == session.id ? s.copyWith(isFavourite: !s.isFavourite) : s,
        )
        .toList();
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'StudyBuddy',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seedColor)),
    home: Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: ListTab(
        sessions: _sessions,
        onOpen: (_) {},
        onToggleFavourite: _toggleFavourite,
      ),
    ),
  );
}
