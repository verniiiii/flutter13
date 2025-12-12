import '../entities/news_entity.dart';

abstract class NewsRepository {
  Future<List<CurrencyRateEntity>> getCurrencyRates();
  Future<List<NewsArticleEntity>> getNews();
  Future<List<NewsArticleEntity>> getTopHeadlines({
    String? country,
    String? category,
    List<String>? sources,
    int pageSize = 20,
    int page = 1,
  });
  Future<List<NewsArticleEntity>> searchNews({
    String? query,
    List<String>? sources,
    List<String>? domains,
    DateTime? from,
    DateTime? to,
    String? language,
    String sortBy = 'publishedAt',
    int pageSize = 20,
    int page = 1,
  });
  Future<List<NewsArticleEntity>> getNewsByCategory({
    required String category,
    String? country,
    int pageSize = 20,
    int page = 1,
  });
  Future<List<NewsArticleEntity>> getNewsBySource({
    required List<String> sources,
    int pageSize = 20,
    int page = 1,
  });
  Future<List<NewsArticleEntity>> getNewsByCountry({
    required String country,
    String? category,
    int pageSize = 20,
    int page = 1,
  });
  Future<NewsArticleEntity?> getNewsById(String id);
  Future<void> markAsRead(String newsId);
}

