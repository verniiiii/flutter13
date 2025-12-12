import 'package:dio/dio.dart';
import '../exceptions.dart';

/// Интерсептор для обработки ошибок и преобразования их в доменные исключения
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    NetworkException exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = TimeoutException(
          'Превышено время ожидания запроса',
          statusCode: err.response?.statusCode,
          originalError: err,
        );
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = _extractErrorMessage(err.response?.data) ??
            err.message ?? 'Произошла ошибка';

        switch (statusCode) {
          case 400:
            exception = BadRequestException(
              message,
              statusCode: statusCode,
              originalError: err,
            );
            break;
          case 401:
            exception = UnauthorizedException(
              message,
              statusCode: statusCode,
              originalError: err,
            );
            break;
          case 403:
            exception = ForbiddenException(
              message,
              statusCode: statusCode,
              originalError: err,
            );
            break;
          case 404:
            exception = NotFoundException(
              message,
              statusCode: statusCode,
              originalError: err,
            );
            break;
          case 429:
            exception = RateLimitException(
              'Превышен лимит запросов',
              statusCode: statusCode,
              originalError: err,
            );
            break;
          default:
          // Проверяем, что statusCode не null и >= 500
            if (statusCode != null && statusCode >= 500) {
              exception = ServerException(
                message,
                statusCode: statusCode,
                originalError: err,
              );
            } else {
              exception = NetworkException(
                message,
                statusCode: statusCode,
                originalError: err,
              );
            }
        }
        break;

      case DioExceptionType.cancel:
        exception = NetworkException(
          'Запрос был отменен',
          originalError: err,
        );
        break;

      case DioExceptionType.connectionError:
        exception = NoInternetException(
          'Нет подключения к интернету',
          originalError: err,
        );
        break;

      case DioExceptionType.unknown:
        if (err.error != null &&
            err.error.toString().contains('SocketException')) {
          exception = NoInternetException(
            'Нет подключения к интернету',
            originalError: err,
          );
        } else {
          exception = UnknownException(
            err.message ?? 'Произошла неизвестная ошибка',
            originalError: err,
          );
        }
        break;

      default:
        exception = UnknownException(
          err.message ?? 'Произошла неизвестная ошибка',
          originalError: err,
        );
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Supabase обычно возвращает ошибки в формате {"message": "..."} или {"error_description": "..."}
      return data['message'] as String? ??
          data['error_description'] as String? ??
          data['error'] as String? ??
          data['msg'] as String?;
    }

    if (data is String) {
      try {
        // Пробуем распарсить JSON строку
        final jsonData = data as Map<String, dynamic>;
        return jsonData['message'] as String? ??
            jsonData['error_description'] as String?;
      } catch (_) {
        return data;
      }
    }

    return null;
  }
}
