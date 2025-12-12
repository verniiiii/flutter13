import '../entities/news_entity.dart';

abstract class NewsRepository {
  Future<List<CurrencyRateEntity>> getCurrencyRates();
  Future<List<NewsArticleEntity>> getNews();
  Future<NewsArticleEntity?> getNewsById(String id);
  Future<void> markAsRead(String newsId);
}

