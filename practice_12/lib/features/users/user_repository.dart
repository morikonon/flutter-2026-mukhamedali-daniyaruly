// ЗАЩИТА (Level 4): репозиторий помнит последний хороший ответ.
// Алгоритм getAll():
//   онлайн → свежие данные + сохранить в кэш → fromCache: false
//   нет сети → взять кэш → fromCache: true
//   нет сети И кэша нет → rethrow → экран показывает честный Offline, а не пустой список.
// Результат — record ({items, fromCache}): экран знает, ОТКУДА данные, и показывает баннер.
// Репозиторий не видит токен и http — только ApiClient.
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

class UserRepository {
  UserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetch();
      await _cache.save(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<List<User>> _fetch() async {
    final data = await _api.getJson('/users');
    if (data is! List) throw const BadResponseException('expected a list');
    try {
      return [for (final e in data) User.fromJson(e as Map<String, dynamic>)];
    } on TypeError catch (e) {
      throw BadResponseException(e.toString());
    }
  }
}
