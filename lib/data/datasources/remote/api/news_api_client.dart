import 'package:dio/dio.dart';
import '../dto/news_api_dto.dart';
import 'exceptions.dart';

/// Клиент для работы с NewsAPI.org на чистом Dio
/// Использует ручную сериализацию без генерации кода
class NewsApiClient {
  final Dio _dio;
  final String _apiKey;

  NewsApiClient({
    required String apiKey,
    Dio? dio,
  })  : _apiKey = apiKey,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://newsapi.org/v2',
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  /// Получение топ новостей (headlines)
  /// 
  /// [country] - код страны (us, ru, gb и т.д.)
  /// [category] - категория (business, technology, sports и т.д.)
  /// [sources] - список источников (bbc-news, cnn и т.д.)
  /// [pageSize] - количество результатов (максимум 100)
  /// [page] - номер страницы
  Future<NewsResponseDto> getTopHeadlines({
    String? country,
    String? category,
    List<String>? sources,
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'apiKey': _apiKey,
        'pageSize': pageSize,
        'page': page,
      };

      if (country != null) queryParams['country'] = country;
      if (category != null) queryParams['category'] = category;
      if (sources != null && sources.isNotEmpty) {
        queryParams['sources'] = sources.join(',');
      }

      final response = await _dio.get(
        '/top-headlines',
        queryParameters: queryParams,
      );

      return NewsResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Поиск новостей по ключевому слову
  /// 
  /// [query] - поисковый запрос
  /// [sources] - список источников
  /// [domains] - список доменов для поиска
  /// [from] - дата начала (ISO 8601)
  /// [to] - дата окончания (ISO 8601)
  /// [language] - язык (en, ru и т.д.)
  /// [sortBy] - сортировка (relevancy, popularity, publishedAt)
  /// [pageSize] - количество результатов
  /// [page] - номер страницы
  Future<NewsResponseDto> searchEverything({
    String? query,
    List<String>? sources,
    List<String>? domains,
    DateTime? from,
    DateTime? to,
    String? language,
    String sortBy = 'publishedAt',
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'apiKey': _apiKey,
        'sortBy': sortBy,
        'pageSize': pageSize,
        'page': page,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (sources != null && sources.isNotEmpty) {
        queryParams['sources'] = sources.join(',');
      }
      if (domains != null && domains.isNotEmpty) {
        queryParams['domains'] = domains.join(',');
      }
      if (from != null) {
        queryParams['from'] = from.toIso8601String();
      }
      if (to != null) {
        queryParams['to'] = to.toIso8601String();
      }
      if (language != null) {
        queryParams['language'] = language;
      }

      final response = await _dio.get(
        '/everything',
        queryParameters: queryParams,
      );

      return NewsResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Получение новостей по категории
  /// 
  /// [category] - категория (business, technology, sports, health, science, entertainment, general)
  /// [country] - код страны
  /// [pageSize] - количество результатов
  /// [page] - номер страницы
  Future<NewsResponseDto> getNewsByCategory({
    required String category,
    String? country,
    int pageSize = 20,
    int page = 1,
  }) async {
    return getTopHeadlines(
      category: category,
      country: country,
      pageSize: pageSize,
      page: page,
    );
  }

  /// Получение новостей по источнику
  /// 
  /// [sources] - список источников (bbc-news, cnn, reuters и т.д.)
  /// [pageSize] - количество результатов
  /// [page] - номер страницы
  Future<NewsResponseDto> getNewsBySource({
    required List<String> sources,
    int pageSize = 20,
    int page = 1,
  }) async {
    return getTopHeadlines(
      sources: sources,
      pageSize: pageSize,
      page: page,
    );
  }

  /// Получение новостей по стране
  /// 
  /// [country] - код страны (us, ru, gb, de, fr и т.д.)
  /// [category] - опциональная категория
  /// [pageSize] - количество результатов
  /// [page] - номер страницы
  Future<NewsResponseDto> getNewsByCountry({
    required String country,
    String? category,
    int pageSize = 20,
    int page = 1,
  }) async {
    return getTopHeadlines(
      country: country,
      category: category,
      pageSize: pageSize,
      page: page,
    );
  }

  /// Получение популярных новостей
  /// Использует searchEverything с сортировкой по популярности
  /// 
  /// [language] - язык (en, ru и т.д.)
  /// [pageSize] - количество результатов
  /// [page] - номер страницы
  Future<NewsResponseDto> getPopularNews({
    String? language,
    int pageSize = 20,
    int page = 1,
  }) async {
    return searchEverything(
      language: language ?? 'en',
      sortBy: 'popularity',
      pageSize: pageSize,
      page: page,
    );
  }

  /// Получение списка доступных источников новостей
  /// 
  /// [category] - фильтр по категории
  /// [language] - фильтр по языку
  /// [country] - фильтр по стране
  Future<NewsSourcesResponseDto> getSources({
    String? category,
    String? language,
    String? country,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'apiKey': _apiKey,
      };

      if (category != null) queryParams['category'] = category;
      if (language != null) queryParams['language'] = language;
      if (country != null) queryParams['country'] = country;

      final response = await _dio.get(
        '/sources',
        queryParameters: queryParams,
      );

      return NewsSourcesResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Обработка ошибок DioException
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
            'Неверный API ключ',
            statusCode: statusCode,
            originalError: error,
          );
        case 429:
          return RateLimitException(
            'Превышен лимит запросов (100 запросов/день для бесплатного тарифа)',
            statusCode: statusCode,
            originalError: error,
          );
        default:
        // Исправь здесь: проверяем, что statusCode не null и >= 500
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
          data['error'] as String? ??
          data['status'] as String?;
    }

    if (data is String) {
      return data;
    }

    return null;
  }
}

