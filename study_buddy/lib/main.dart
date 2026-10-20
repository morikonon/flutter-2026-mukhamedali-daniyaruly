import 'package:flutter/material.dart';

import 'data/seed.dart';
import 'utils/format.dart';

// The only literal colour in lib/: every other colour comes from the scheme.
const seedColor = Colors.indigo;

void main() {
  _debugChecks();
  runApp(const MyApp());
}

// Step 1 only: prints derived values so the model can be checked by eye.
void _debugChecks() {
  final now = DateTime.now();
  for (final s in seedItems()) {
    final (:taken, :free) = s.places;
    debugPrint(
      '${s.id}: ${s.title.length} chars, $taken taken, $free free, '
      'full=${s.isFull}, past=${s.isPast}, '
      '${formatDateTime(s.startsAt)}, ${formatCountdown(s.countdown(now))}',
    );
  }
}

/// Temporary home screen for step 1: just the seed titles.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = seedItems();
    return MaterialApp(
      title: 'StudyBuddy',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seedColor)),
      home: Scaffold(
        appBar: AppBar(title: const Text('StudyBuddy')),
        body: ListView(
          children: [
            for (final s in sessions)
              ListTile(
                leading: Icon(s.subject.icon),
                title: Text(s.title),
                subtitle: Text(
                  '${formatDateTime(s.startsAt)} · ${s.subject.label}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
