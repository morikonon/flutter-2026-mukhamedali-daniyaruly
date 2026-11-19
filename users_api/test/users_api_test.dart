import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';

// Тесты без сети: вместо настоящего http.Client подставляем MockClient.
// Это и есть польза от того, что ApiClient получает клиента через конструктор.
UserRepository _repo(int status, String body) => UserRepository(
  ApiClient(MockClient((_) async => http.Response(body, status))),
);

const _user1 = {
  'id': 1,
  'name': 'Leanne Graham',
  'username': 'Bret',
  'email': 'Sincere@april.biz',
  'address': {
    'street': 'Kulas Light',
    'suite': 'Apt. 556',
    'city': 'Gwenborough',
    'zipcode': '92998-3874',
    'geo': {'lat': '-37.3159', 'lng': '81.1496'},
  },
  'phone': '1-770-736-8031 x56442',
  'website': 'hildegard.org',
  'company': {'name': 'Romaguera-Crona', 'catchPhrase': 'Multi-layered'},
};

void main() {
  test('fromJson parses nested objects and lat as double', () {
    final u = User.fromJson(_user1);
    expect(u.address.geo.lat, -37.3159);
    expect(u.company.name, 'Romaguera-Crona');
    expect(u.phoneDigits, '1770736803156442');
  });

  test('toJson round-trip gives an equal user', () {
    final u = User.fromJson(_user1);
    expect(User.fromJson(u.toJson()), u);
    expect(u.toJson()['address'], _user1['address']);
  });

  test('missing website is null, not a crash', () {
    final json = Map<String, dynamic>.of(_user1)..remove('website');
    expect(User.fromJson(json).website, isNull);
  });

  test('200 with a list -> users', () async {
    final users = await _repo(200, jsonEncode([_user1])).getAll();
    expect(users.single.name, 'Leanne Graham');
  });

  test('404 -> NotFoundException (status before body)', () {
    expect(_repo(404, '{}').getById(999), throwsA(isA<NotFoundException>()));
  });

  test('401 -> UnauthorizedException', () {
    expect(_repo(401, '{}').getAll(), throwsA(isA<UnauthorizedException>()));
  });

  test('503 -> ServerException with status', () {
    expect(
      _repo(503, '').getAll(),
      throwsA(isA<ServerException>().having((e) => e.status, 'status', 503)),
    );
  });

  test('not JSON -> BadResponseException', () {
    expect(_repo(200, '<html>').getAll(), throwsA(isA<BadResponseException>()));
  });

  test('id as a string -> BadResponseException naming the cause', () {
    final body = jsonEncode({..._user1, 'id': '1'});
    expect(_repo(200, body).getById(1), throwsA(isA<BadResponseException>()));
  });

  test('network failure -> NoConnectionException', () {
    final repo = UserRepository(
      ApiClient(MockClient((_) async => throw http.ClientException('down'))),
    );
    expect(repo.getAll(), throwsA(isA<NoConnectionException>()));
  });

  test('create expects 201 and returns the server id', () async {
    final repo = UserRepository(
      ApiClient(
        MockClient((req) async {
          expect(req.headers['Content-Type'], startsWith('application/json'));
          final sent = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response(jsonEncode({...sent, 'id': 11}), 201);
        }),
      ),
    );
    final created = await repo.create(
      const User.draft(name: 'A B', username: 'ab', email: 'a@b.kz'),
    );
    expect(created.id, 11);
  });
}
