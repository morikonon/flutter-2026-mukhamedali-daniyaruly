// ЗАЩИТА: sealed class — компилятор знает ВСЕ подтипы, поэтому switch на экране
// обязан обработать каждый случай (иначе ошибка компиляции).
// Три «кучи» ошибок: нет связи / их сервер (5xx) / мой запрос (4xx) + битый JSON.
sealed class ApiException implements Exception {
  const ApiException();
}

// нет ответа вообще: SocketException или таймаут → на этом UsersCache отдаёт сохранённое
class NoConnectionException extends ApiException {
  const NoConnectionException();
}

class ServerException extends ApiException {
  const ServerException(this.status);
  final int status;
}

class NotFoundException extends ApiException {
  const NotFoundException();
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException();
}

class BadResponseException extends ApiException {
  const BadResponseException([this.detail]);
  final String? detail;
}
