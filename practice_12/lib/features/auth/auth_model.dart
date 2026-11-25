// ЗАЩИТА (Level 3): фейковый логин + настоящее безопасное хранилище.
// - Пароль 8+ символов → через 1 секунду токен 'tok_${email.hashCode}'.
// - Токен сразу в SecureStore (Keychain/Keystore), НИКОГДА не в shared_preferences и не print.
// - В main() токен читается при старте и передаётся сюда → после перезапуска мы всё ещё вошли.
// - logout() → clear() удаляет токен → следующий запуск покажет экран логина.
import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, [this._token]);

  final SecureStore _store;
  String? _token;

  bool get signedIn => _token != null;
  String? get token => _token;

  // возвращает false, если пароль короткий — экран покажет ошибку
  Future<bool> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (password.length < 8) return false;
    final t = 'tok_${email.hashCode}';
    await _store.saveToken(t);
    _token = t;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }
}
