// Три «кучи» ошибок из лекции, оформленные как классы.
// sealed = все наследники известны компилятору и лежат в этом файле,
// поэтому switch по ApiException на экране обязан быть исчерпывающим
// (без default). Добавишь новый класс — экран перестанет компилироваться,
// пока ты его не обработаешь.
sealed class ApiException implements Exception {
  const ApiException();
}

// Ответа нет вообще: SocketException (нет маршрута, неверный host)
// или TimeoutException (пакеты ушли и не вернулись за 10 секунд).
class NoConnectionException extends ApiException {
  const NoConnectionException();
}

// Их сервер сломался: 5xx. Retry имеет смысл.
class ServerException extends ApiException {
  const ServerException(this.status);
  final int status;
}

// Мой запрос неверный: 4xx. Retry не поможет.
class NotFoundException extends ApiException {
  const NotFoundException();
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException();
}

// JSON, который мы не смогли прочитать: это баг-репорт, а не Retry.
class BadResponseException extends ApiException {
  const BadResponseException([this.detail]);
  final String? detail;

  @override
  String toString() => 'BadResponseException: ${detail ?? 'no detail'}';
}
