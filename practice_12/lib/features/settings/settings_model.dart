// ЗАЩИТА (Level 2): настройки в shared_preferences.
// - Начальные значения читаются в main() ДО runApp и приходят через конструктор →
//   тёмная тема с первого кадра, без «вспышки» светлой.
// - setDark: сначала notifyListeners() (экран сразу меняется), ПОТОМ await записи на диск —
//   UI не ждёт диск.
// - setCity(null) удаляет ключ (remove), иначе пишет строку.
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(this._prefs, {required this.dark, this.city, this.avatarPath});

  final SharedPreferencesAsync _prefs;
  bool dark;
  String? city;
  String? avatarPath;

  Future<void> setDark(bool v) async {
    dark = v;
    notifyListeners();
    await _prefs.setBool('darkMode', v);
  }

  Future<void> setCity(String? c) async {
    city = c;
    notifyListeners();
    if (c == null) {
      await _prefs.remove('cityFilter');
    } else {
      await _prefs.setString('cityFilter', c);
    }
  }

  // Level 5: путь к фото в prefs, сам файл — в Documents
  Future<void> setAvatar(String path) async {
    avatarPath = path;
    notifyListeners();
    await _prefs.setString('avatarPath', path);
  }
}
