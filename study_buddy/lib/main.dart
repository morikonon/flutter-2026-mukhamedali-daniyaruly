import 'package:flutter/material.dart';

import 'routes.dart';
import 'shell.dart';

// The only literal colour in lib/: every other colour comes from the scheme.
const seedColor = Colors.indigo;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Above MaterialApp, so a change rebuilds the theme of the whole app.
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'StudyBuddy',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seedColor)),
    themeMode: _themeMode,
    initialRoute: Routes.home,
    routes: {
      Routes.home: (_) =>
          Shell(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
    },
    onGenerateRoute: generateRoute,
    onUnknownRoute: unknownRoute,
  );
}
