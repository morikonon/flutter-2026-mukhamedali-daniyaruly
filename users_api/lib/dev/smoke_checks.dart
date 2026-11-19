import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../features/users/user.dart';
import '../features/users/user_repository.dart';

// Реальный JSON пользователя 1, скопированный из Postman/curl.
// Для эксперимента Level 2: поменяй "id": 1 на "id": "1" — упадёт каст на id.
const _user1 = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {"lat": "-37.3159", "lng": "81.1496"}
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';

Future<void> runSmokeChecks(UserRepository repo) async {
  // Level 2: модель без сети и без экрана.
  final user = User.fromJson(jsonDecode(_user1) as Map<String, dynamic>);
  debugPrint('L2 parsed: $user, phoneDigits=${user.phoneDigits}');
  debugPrint('L2 round-trip equal: ${User.fromJson(user.toJson()) == user}');

  // Level 3: репозиторий против настоящего сервера.
  final all = await repo.getAll();
  debugPrint('L3 getAll: ${all.length} users');
  for (final u in all) {
    debugPrint('  ${u.name}');
  }

  try {
    await repo.getById(999);
  } on NotFoundException {
    debugPrint('L3 getById(999): not found');
  }

  final created = await repo.create(
    const User.draft(
      name: 'Smoke Test',
      username: 'smoke',
      email: 'smoke@test.kz',
    ),
  );
  debugPrint('L3 create: server assigned id ${created.id}');
}
