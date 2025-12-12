/// Базовое исключение для сетевых ошибок
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  NetworkException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => message;
}

/// Исключение при таймауте запроса
class TimeoutException extends NetworkException {
  TimeoutException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

/// Исключение при отсутствии подключения к интернету
class NoInternetException extends NetworkException {
  NoInternetException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

class RateLimitException extends NetworkException {
  RateLimitException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

/// Исключение при ошибке авторизации (401)
class UnauthorizedException extends NetworkException {
  UnauthorizedException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

/// Исключение при ошибке доступа (403)
class ForbiddenException extends NetworkException {
  ForbiddenException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

/// Исключение при ошибке "Не найдено" (404)
class NotFoundException extends NetworkException {
  NotFoundException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

/// Исключение при ошибке сервера (5xx)
class ServerException extends NetworkException {
  ServerException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

/// Исключение при ошибке валидации (400)
class BadRequestException extends NetworkException {
  BadRequestException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

/// Исключение при неизвестной ошибке
class UnknownException extends NetworkException {
  UnknownException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

