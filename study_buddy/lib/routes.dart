import 'package:flutter/material.dart';

import 'models/session.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

/// The only place in lib/ with route strings.
abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

/// Everything the detail screen needs. The callbacks let it report
/// changes to the shell, which owns the list.
class DetailArgs {
  const DetailArgs({
    required this.session,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Session session;
  final String profileName;
  final ValueChanged<Session> onChanged;
  final ValueChanged<String> onDelete;
  final VoidCallback onOpenProfile;
}

/// null means "a new session"; otherwise the session to edit.
class FormArgs {
  const FormArgs(this.session);

  final Session? session;
}

Route<dynamic>? generateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case Routes.detail:
      if (args is DetailArgs) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => DetailScreen(args: args),
        );
      }
    case Routes.form:
      if (args is FormArgs) {
        // Typed <Session> to match pushNamed<Session>: the form answers
        // with the saved session.
        return MaterialPageRoute<Session>(
          settings: settings,
          builder: (_) => FormScreen(args: args),
        );
      }
  }
  // Unknown name or wrong argument type: onUnknownRoute takes over.
  return null;
}

Route<dynamic> unknownRoute(RouteSettings settings) => MaterialPageRoute<void>(
  settings: settings,
  builder: (_) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: const Center(child: Text('Not found')),
  ),
);
