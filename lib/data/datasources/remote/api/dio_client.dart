import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'exceptions.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final String baseUrl;

  DioClient({
    required this.baseUrl,
    required FlutterSecureStorage secureStorage,
  }) : _secureStorage = secureStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthInterceptor(_secureStorage),
      ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}

