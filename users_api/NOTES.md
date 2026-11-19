# Notes — A Real Server

## Level 1 — Postman first

`GET https://jsonplaceholder.typicode.com/users` → **200**,
`Content-Type: application/json; charset=utf-8`, тело — **JSON-массив из 10 пользователей**.
`GET …/users/1` → 200, тело — **один объект** (не массив).

Ключи пользователя: `id, name, username, email, address, phone, website, company`.
Вложенные объекты: `address`, `company`. Вложенный дважды: `address.geo`.
Ни одно поле в реальных данных не отсутствует и не null; `website` я всё равно
читаю как `String?` — это единственное поле, которое модель считает необязательным.

### User

| field    | JSON type | Dart type | nullable? |
|----------|-----------|-----------|-----------|
| id       | number    | int       | no        |
| name     | string    | String    | no        |
| username | string    | String    | no        |
| email    | string    | String    | no        |
| address  | object    | Address   | no        |
| phone    | string    | String    | no        |
| website  | string    | String?   | yes (по решению модели) |
| company  | object    | ({String name, String catchPhrase}) record | no |

### Address

| field   | JSON type | Dart type | nullable? |
|---------|-----------|-----------|-----------|
| street  | string    | String    | no        |
| suite   | string    | String    | no        |
| city    | string    | String    | no        |
| zipcode | string    | String    | no        |
| geo     | object    | Geo       | no        |

### Geo (address.geo)

| field | JSON type                  | Dart type                | nullable? |
|-------|----------------------------|--------------------------|-----------|
| lat   | string (`"-37.3159"`)      | double (`double.parse`)  | no        |
| lng   | string (`"81.1496"`)       | double (`double.parse`)  | no        |

### Company

| field       | JSON type | Dart type | nullable? |
|-------------|-----------|-----------|-----------|
| name        | string    | String    | no        |
| catchPhrase | string    | String    | no        |
| bs          | string    | — (модель не хранит) | — |

### Статусы

| запрос | статус | тело |
|--------|--------|------|
| `GET /users/999` | **404** | `{}` — пустой объект. Поэтому статус проверяем до тела: иначе `{}` дойдёт до `fromJson` и упадёт на `id` |
| `POST /users` + `Content-Type: application/json` | **201 Created** | возвращает то, что мы прислали, **плюс `"id": 11`** |
| `GET /users?id=3` | 200 | **массив из одного** объекта, не объект |

## Level 2 — модель

- `debugPrint(user)` → `User(1, Leanne Graham, Gwenborough)`; round-trip `fromJson(toJson())` равен исходному.
- `json['lat'] as double` → `type 'String' is not a subtype of type 'double' in type cast` — каст назвал поле. Вернул `double.parse`.
- `"id": "1"` в JSON → `type 'String' is not a subtype of type 'int'` — та же ошибка, на `id`. В репозитории она становится `BadResponseException('users/1: …')`.

## Level 3 — репозиторий

Запуск: `flutter run -d chrome --dart-define=SMOKE=true` (проверено против живого сервера)

```
L3 getAll: 10 users
L3 getById(999): not found
L3 create: server assigned id 11
```

`grep -rn "package:http" lib/`:

```
lib/main.dart:2               ← composition root: единственный `http.Client()`
lib/core/api/api_client.dart:7
```

`UserRepository` не импортирует `http` вообще: `_send/_check/_decode` приватные
в `ApiClient`, репозиторий получает от него уже декодированный JSON. Экраны,
модель и виджеты про http не знают.

Эксперимент «забыть 404 в `_check`» (и убрать запасную ветку для прочих
статусов): `_decode` проходит (тело `{}`), `fromJson` падает на первом же касте →
`BadResponseException: users/999: TypeError: type 'Null' is not a subtype of type 'Map<String, dynamic>'`
(первым в моём `fromJson` читается `company`). Ошибка наша, но причина указана
неверно — на самом деле это 404. Строку 404 вернул.

## Level 4 — цепочка

- Опечатка в host (`jsonplaceholder.typicode.co`) → `NoConnectionException` за **~0.3 с** → Offline + Retry.
- Удаление ветки `BadResponseException()` из switch → не компилируется:
  `The type 'ApiException?' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'BadResponseException()'` (`non_exhaustive_switch_expression`).

## Level 5 — два вида «нет сети»

| тест | что происходит | время до Offline |
|------|----------------|------------------|
| Авиарежим | ОС сразу знает, что маршрута нет → `SocketException` | ___ с (заполнить) |
| Wi-Fi без интернета | пакеты уходят и не возвращаются → `TimeoutException` через 10 с | ___ с (заполнить) |

DevTools → Network: `screenshot_timeout.png` (строка `/users` без статуса, ~10 000 ms),
`screenshot_200.png` (строка 200 с открытым телом). POST из формы — один запрос, 201.
