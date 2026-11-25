// ЗАЩИТА (Level 3): токен = «то, что позволяет кому-то быть тобой» → только secure storage.
// iOS: Keychain, Android: Keystore (шифрование ключом, который не покидает устройство).
// В shared_preferences токен лежал бы открытым текстом в XML/plist — его прочтёт бэкап, root, кабель.
// Обёртка нужна, чтобы остальной код не знал о конкретном пакете (легко подменить в тестах).
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  const SecureStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;
  static const _tokenKey = 'token';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
