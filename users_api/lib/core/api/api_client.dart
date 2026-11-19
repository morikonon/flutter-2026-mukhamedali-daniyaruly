import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

// Единственное место, где живут http.Response, статус-коды и jsonDecode.
// Наружу отдаёт уже декодированный JSON (dynamic) или одно из наших
// ApiException — никогда Response.
class ApiClient {
  // http.Client приходит через конструктор (dependency injection):
  // в приложении это настоящий http.Client(), в тестах — MockClient.
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  static const _timeout = Duration(seconds: 10);

  // Заголовки в одном месте, а не размазаны по каждому запросу.
  Map<String, String> get _headers => const {'Accept': 'application/json'};

  Future<dynamic> get(Uri uri) async {
    final r = await _send(() => _client.get(uri, headers: _headers));
    _check(r);
    return _decode(r);
  }

  // body уже закодирован репозиторием (jsonEncode(draft.toJson())).
  // expect — какой статус считаем успехом: для создания это 201 Created.
  Future<dynamic> post(Uri uri, String body, {int expect = 201}) async {
    final r = await _send(
      () => _client.post(
        uri,
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: body,
      ),
    );
    _check(r);
    if (r.statusCode != expect) {
      throw BadResponseException(
        'POST $uri: expected $expect, got ${r.statusCode}',
      );
    }
    return _decode(r);
  }

  // Шаг 1: был ли вообще ответ?
  // Без .timeout запрос в «мёртвый» Wi-Fi висит минутами; с ним — 10 секунд.
  Future<http.Response> _send(Future<http.Response> Function() call) async {
    final watch = Stopwatch()..start();
    try {
      final r = await call().timeout(_timeout);
      if (kDebugMode) {
        log(
          '${r.request?.method} ${r.request?.url} → ${r.statusCode} '
          '(${watch.elapsedMilliseconds} ms)',
          name: 'api',
        );
      }
      return r;
    } on SocketException {
      // Авиарежим или опечатка в host: ОС сразу знает, что маршрута нет.
      throw const NoConnectionException();
    } on TimeoutException {
      // Пакеты ушли и не вернулись: Wi-Fi без интернета.
      throw const NoConnectionException();
    } on http.ClientException {
      // В браузере (flutter run -d chrome) SocketException не бывает:
      // http сообщает об обрыве сети через ClientException.
      throw const NoConnectionException();
    }
  }

  // Шаг 2: статус проверяем ДО тела. Иначе 404 с телом {} дойдёт до
  // fromJson и упадёт на 'id' — ошибка будет наша, но причина неверная.
  void _check(http.Response r) {
    switch (r.statusCode) {
      case >= 200 && < 300:
        return;
      case 401:
        throw const UnauthorizedException();
      case 404:
        throw const NotFoundException();
      case >= 500:
        throw ServerException(r.statusCode);
      case final status:
        throw BadResponseException('${r.request?.url}: status $status');
    }
  }

  // Шаг 3: тело — это вообще JSON? FormatException превращаем в свою ошибку.
  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('${r.request?.url}: not JSON (${e.message})');
    }
  }
}
