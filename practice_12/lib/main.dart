// ЗАЩИТА: порядок в main() важен — binding → диск → runApp.
// 1. WidgetsFlutterBinding.ensureInitialized() — до любого плагина (prefs, secure storage).
// 2. Читаем настройки и токен ДО первого кадра → тёмная тема без вспышки, логин уже известен.
//    Каждое чтение nullable и получает значение по умолчанию через ?? — без ! и без late.
// 3. Всё создаём здесь и передаём через конструкторы (DI), дальше — Provider.
// Сломать специально: перенести getBool в конструктор SettingsModel → один светлый кадр, потом тёмный.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');
  final avatar = await prefs.getString('avatarPath');

  const store = SecureStore();
  final token = await store.readToken();

  final api = ApiClient(http.Client(), store);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              SettingsModel(prefs, dark: dark, city: city, avatarPath: avatar),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token)),
        ChangeNotifierProvider(
          create: (_) => UsersModel(UserRepository(api, UsersCache()))..load(),
        ),
      ],
      child: const App(),
    ),
  );
}
