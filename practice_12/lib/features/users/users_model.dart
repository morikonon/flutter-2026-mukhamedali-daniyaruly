// ЗАЩИТА: ChangeNotifier-состояние списка: loading / error / items + fromCache.
// fromCache = true → экран показывает баннер «Saved data · no connection · Retry».
// Retry офлайн оставляет данные и баннер; Retry онлайн — баннер исчезает.
import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = [];
  bool loading = false;
  bool fromCache = false;
  ApiException? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repo.getAll();
      items = result.items;
      fromCache = result.fromCache;
    } on ApiException catch (e) {
      // если старые данные уже на экране — оставляем их и просто показываем баннер
      if (items.isEmpty) {
        error = e;
      } else {
        fromCache = true;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
