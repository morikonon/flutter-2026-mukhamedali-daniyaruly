# users_api — Practice 11: A Real Server

Список пользователей с `jsonplaceholder.typicode.com`, детальный экран и форма создания (POST).

```
lib/
  main.dart                       composition root: http.Client() → ApiClient → UserRepository → UsersModel
  core/api/
    api_exception.dart            sealed ApiException и наследники
    api_client.dart               _send (timeout 10 s) → _check (статус) → _decode (JSON)
  features/users/
    user.dart                     Geo, Address, User (+ company как record)
    user_repository.dart          getAll / getById / create, Uri.https, ошибки fromJson → BadResponseException
    users_model.dart              ChangeNotifier: loading / error / items / saving
    users_screen.dart             watch + исчерпывающий switch по ошибке
    user_detail_screen.dart
    new_user_screen.dart          форма POST, Save выключен во время запроса
    widgets/                      UserList (RefreshIndicator), экраны-состояния
  dev/smoke_checks.dart           проверки Level 2–3 (--dart-define=SMOKE=true)
test/users_api_test.dart          MockClient: 404/401/5xx/bad JSON/no network/POST
```

```
flutter run -d chrome
flutter run -d chrome --dart-define=SMOKE=true
flutter test --platform chrome
flutter analyze
```
