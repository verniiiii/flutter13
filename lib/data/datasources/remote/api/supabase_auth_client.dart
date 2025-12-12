import 'package:dio/dio.dart';
import '../dto/auth_dto.dart';
import 'exceptions.dart';

/// Клиент для работы с Supabase Auth API на чистом Dio
/// Использует ручную сериализацию без генерации кода
/// Альтернатива Retrofit-подходу
class SupabaseAuthClient {
  final Dio _dio;
  final String baseUrl;
  final String apiKey;

  SupabaseAuthClient({
    required this.baseUrl,
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'apikey': apiKey,
                },
              ),
            );

  /// Регистрация нового пользователя
  /// POST /auth/v1/signup
  Future<AuthResponseDto> signUp(SignUpRequestDto request) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: request.toJson(),
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Вход пользователя
  /// POST /auth/v1/token?grant_type=password
  Future<AuthResponseDto> signIn(
    SignInRequestDto request,
  ) async {
    try {
      final response = await _dio.post(
        '/token',
        queryParameters: {'grant_type': 'password'},
        data: request.toJson(),
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Получение данных текущего пользователя
  /// GET /auth/v1/user
  Future<UserResponseDto> getUser({String? accessToken}) async {
    try {
      final headers = <String, dynamic>{};
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await _dio.get(
        '/user',
        options: Options(headers: headers),
      );

      return UserResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Обновление токена доступа
  /// POST /auth/v1/token?grant_type=refresh_token
  Future<RefreshTokenResponseDto> refreshToken(
    RefreshTokenRequestDto request,
  ) async {
    try {
      final response = await _dio.post(
        '/token',
        queryParameters: {'grant_type': 'refresh_token'},
        data: request.toJson(),
      );

      return RefreshTokenResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Выход пользователя
  /// POST /auth/v1/logout
  Future<void> logout({String? accessToken}) async {
    try {
      final headers = <String, dynamic>{};
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      await _dio.post(
        '/logout',
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Обновление пароля пользователя
  /// PUT /auth/v1/user
  Future<UserResponseDto> updatePassword(
    UpdatePasswordRequestDto request, {
    String? accessToken,
  }) async {
    try {
      final headers = <String, dynamic>{};
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await _dio.put(
        '/user',
        data: request.toJson(),
        options: Options(headers: headers),
      );

      return UserResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Обновление профиля пользователя
  /// PUT /auth/v1/user
  Future<UserResponseDto> updateProfile(
    UpdateProfileRequestDto request, {
    String? accessToken,
  }) async {
    try {
      final headers = <String, dynamic>{};
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await _dio.put(
        '/user',
        data: request.toJson(),
        options: Options(headers: headers),
      );

      return UserResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Восстановление пароля
  /// POST /auth/v1/recover
  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _dio.post(
        '/recover',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Обработка ошибок DioException
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = _extractErrorMessage(error.response!.data) ??
          error.message ??
          'Произошла ошибка';

      switch (statusCode) {
        case 400:
          return BadRequestException(
            message,
            statusCode: statusCode,
            originalError: error,
          );
        case 401:
          return UnauthorizedException(
            message,
            statusCode: statusCode,
            originalError: error,
          );
        case 403:
          return ForbiddenException(
            message,
            statusCode: statusCode,
            originalError: error,
          );
        case 404:
          return NotFoundException(
            message,
            statusCode: statusCode,
            originalError: error,
          );
        case 429:
          return RateLimitException(
            'Превышен лимит запросов',
            statusCode: statusCode,
            originalError: error,
          );
        default:
          if (statusCode != null && statusCode >= 500) {
            return ServerException(
              message,
              statusCode: statusCode,
              originalError: error,
            );
          } else {
            return NetworkException(
              message,
              statusCode: statusCode,
              originalError: error,
            );
          }
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return TimeoutException(
        'Превышено время ожидания запроса',
        originalError: error,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return NoInternetException(
        'Нет подключения к интернету',
        originalError: error,
      );
    }

    return UnknownException(
      error.message ?? 'Произошла неизвестная ошибка',
      originalError: error,
    );
  }

  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
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

