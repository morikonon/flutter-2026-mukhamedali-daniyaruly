import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

// Состояние экрана списка: loading / error / items.
// Это не State (нет BuildContext и mounted) и не репозиторий (нет http).
// Модель меняет поля и зовёт notifyListeners() — Consumer/watch перерисуют.
class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;

  // true, пока POST в полёте: кнопка Save на это время выключена,
  // поэтому двойной тап отправляет один запрос.
  bool saving = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.getAll();
    } on ApiException catch (e) {
      // Ловим только свои ошибки. Баг в коде (не ApiException) не глотаем —
      // он должен упасть громко, а не превратиться в «пустой список».
      error = e;
    } finally {
      // finally — чтобы спиннер выключился при любом исходе.
      loading = false;
      notifyListeners();
    }
  }

  // Ошибку здесь не ловим: её показывает форма (SnackBar), а список
  // остаётся как был. finally гарантирует, что saving вернётся в false.
  Future<void> create(User draft) async {
    if (saving) return;
    saving = true;
    notifyListeners();
    try {
      final created = await _repo.create(draft);
      items = [created, ...items]; // новый список, а не мутация старого
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
