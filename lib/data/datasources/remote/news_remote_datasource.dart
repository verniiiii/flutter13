import '../../../core/models/news_model.dart';
import '../../models/mappers/news_api_mapper.dart';
import 'api/exceptions.dart';
import 'api/news_api_client.dart';
import 'dto/news_api_dto.dart';

/// Remote DataSource для получения новостей из NewsAPI.org
class NewsRemoteDataSource {
  final NewsApiClient _apiClient;

  NewsRemoteDataSource({
    required NewsApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Получение топ новостей
  Future<List<NewsArticle>> getTopHeadlines({
    String? country,
    String? category,
    List<String>? sources,
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.getTopHeadlines(
        country: country,
        category: category,
        sources: sources,
        pageSize: pageSize,
        page: page,
      );

      return response.articles
          .map((dto) => NewsApiMapper.articleDtoToModel(dto))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Поиск новостей по ключевому слову
  Future<List<NewsArticle>> searchEverything({
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
      final response = await _apiClient.searchEverything(
        query: query,
        sources: sources,
        domains: domains,
        from: from,
        to: to,
        language: language,
        sortBy: sortBy,
        pageSize: pageSize,
        page: page,
      );

      return response.articles
          .map((dto) => NewsApiMapper.articleDtoToModel(dto))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Получение новостей по категории
  Future<List<NewsArticle>> getNewsByCategory({
    required String category,
    String? country,
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.getNewsByCategory(
        category: category,
        country: country,
        pageSize: pageSize,
        page: page,
      );

      return response.articles
          .map((dto) => NewsApiMapper.articleDtoToModel(dto))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Получение новостей по источнику
  Future<List<NewsArticle>> getNewsBySource({
    required List<String> sources,
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.getNewsBySource(
        sources: sources,
        pageSize: pageSize,
        page: page,
      );

      return response.articles
          .map((dto) => NewsApiMapper.articleDtoToModel(dto))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Получение новостей по стране
  Future<List<NewsArticle>> getNewsByCountry({
    required String country,
    String? category,
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.getNewsByCountry(
        country: country,
        category: category,
        pageSize: pageSize,
        page: page,
      );

      return response.articles
          .map((dto) => NewsApiMapper.articleDtoToModel(dto))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Получение списка доступных источников
  Future<List<NewsSourceDto>> getSources({
    String? category,
    String? language,
    String? country,
  }) async {
    try {
      final response = await _apiClient.getSources(
        category: category,
        language: language,
        country: country,
      );

      return response.sources;
    } catch (e) {
      throw _handleError(e);
    }
  }


  /// Обработка ошибок
  Exception _handleError(dynamic error) {
    if (error is NetworkException) {
      return error;
    }

    if (error is Exception) {
      return UnknownException(
        error.toString(),
        originalError: error,
      );
    }

    return UnknownException(
      'Произошла неизвестная ошибка',
      originalError: error,
    );
  }
}

