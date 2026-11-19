import 'dart:convert';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

// Экран просит у репозитория модели и получает модели — или ApiException.
// Никаких Response, статус-кодов и Map наружу.
class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    // Адрес только через Uri.https — он сам экранирует путь и query,
    // никакой склейки строк.
    final json = await _api.get(Uri.https(_api.host, '/users'));
    return _parse('users', () {
      final list = json as List<dynamic>;
      return [
        for (final item in list) User.fromJson(item as Map<String, dynamic>),
      ];
    });
  }

  Future<User> getById(int id) async {
    final json = await _api.get(Uri.https(_api.host, '/users/$id'));
    return _parse(
      'users/$id',
      () => User.fromJson(json as Map<String, dynamic>),
    );
  }

  // POST: сервер возвращает то, что мы прислали, + назначенный id (11).
  Future<User> create(User draft) async {
    // id убираем — его назначает сервер, а не клиент.
    final body = jsonEncode(draft.toJson()..remove('id'));
    final json = await _api.post(Uri.https(_api.host, '/users'), body);
    return _parse(
      'POST users',
      () => User.fromJson(json as Map<String, dynamic>),
    );
  }

  // Неверный каст (TypeError) или double.parse("abc") (FormatException)
  // внутри fromJson превращаются в нашу ошибку с указанием, где упало.
  // Ловим только эти два типа — никакого пустого catch (e) {}.
  T _parse<T>(String where, T Function() read) {
    try {
      return read();
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
