// ЗАЩИТА (Level 4): кэш последнего удачного списка.
// - getApplicationDocumentsDirectory(): данные живут, пока приложение установлено.
//   НЕ getTemporaryDirectory(): ОС чистит его когда хочет (Clear cache) — список пропадёт молча.
// - Путь никогда не хардкодим: он разный на Android/iOS и между установками.
// - load() возвращает null, если файла нет (первый запуск офлайн) → репозиторий делает rethrow.
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

class UsersCache {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/users.json');
  }

  Future<void> save(List<User> list) async {
    final file = await _file();
    await file.writeAsString(jsonEncode([for (final u in list) u.toJson()]));
  }

  Future<List<User>?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    final data = jsonDecode(await file.readAsString()) as List<dynamic>;
    return [for (final e in data) User.fromJson(e as Map<String, dynamic>)];
  }
}
