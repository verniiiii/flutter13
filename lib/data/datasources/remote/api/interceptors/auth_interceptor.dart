import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Интерсептор для автоматического добавления токена авторизации в заголовки
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  static const String _accessTokenKey = 'access_token';

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Получаем токен из безопасного хранилища
    final token = await _secureStorage.read(key: _accessTokenKey);

    // Добавляем токен в заголовок Authorization, если он есть
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }
}

