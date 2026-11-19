import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'dev/smoke_checks.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

// Проверки уровней 2–3 в консоли до runApp:
// flutter run --dart-define=SMOKE=true
const _smoke = bool.fromEnvironment('SMOKE');

Future<void> main() async {
  // Composition root: единственное место, где создаётся http.Client()
  // и собирается цепочка ApiClient -> UserRepository -> UsersModel.
  final repo = UserRepository(ApiClient(http.Client()));

  if (_smoke) await runSmokeChecks(repo);

  runApp(
    ChangeNotifierProvider(
      // ..load() — каскад: создаём модель и сразу стартуем загрузку.
      create: (_) => UsersModel(repo)..load(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Users API',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    ),
    home: const UsersScreen(),
  );
}
