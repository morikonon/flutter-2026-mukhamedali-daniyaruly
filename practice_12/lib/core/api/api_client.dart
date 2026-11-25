// ЗАЩИТА (Level 3):
// - ApiClient — единственный класс (кроме main.dart), который импортирует package:http.
//   grep "package:http" lib/ печатает только этот файл и main.dart.
// - http.Client и SecureStore приходят через конструктор (dependency injection) →
//   в тестах можно подменить фейком.
// - Заголовок Authorization добавляется ЗДЕСЬ сам: репозиторий не видит токен,
//   экран не видит заголовок. `if (... case final t?)` — collection-if с pattern:
//   ключ попадает в Map только если токен не null (без !).
// - Таймаут 10 секунд; SocketException/TimeoutException → NoConnectionException.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, this._store);

  final http.Client _client;
  final SecureStore _store;

  static const _host = 'jsonplaceholder.typicode.com';

  Future<Object?> getJson(String path) async {
    final headers = {
      'Accept': 'application/json',
      if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
    };
    final http.Response res;
    try {
      res = await _client
          .get(Uri.https(_host, path), headers: headers)
          .timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
    _check(res.statusCode);
    try {
      return jsonDecode(res.body);
    } on FormatException catch (e) {
      throw BadResponseException(e.message);
    }
  }

  void _check(int status) {
    if (status >= 200 && status < 300) return;
    if (status == 401) throw const UnauthorizedException();
    if (status == 404) throw const NotFoundException();
    if (status >= 500) throw ServerException(status);
    throw BadResponseException('HTTP $status');
  }
}
