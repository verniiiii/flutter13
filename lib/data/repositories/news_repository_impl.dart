import '../../domain/repositories/news_repository.dart';
import '../../domain/entities/news_entity.dart';
import '../datasources/local/news_local_datasource.dart';
import '../datasources/remote/news_remote_datasource.dart';
import '../../core/models/news_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsLocalDataSource localDataSource;
  final NewsRemoteDataSource? remoteDataSource;

  NewsRepositoryImpl(
    this.localDataSource, {
    this.remoteDataSource,
  });

  CurrencyRateEntity _rateModelToEntity(CurrencyRate model) {
    return CurrencyRateEntity(
      code: model.code,
      name: model.name,
      rate: model.rate,
      change: model.change,
      changePercent: model.changePercent,
      symbol: model.symbol,
    );
  }

  NewsArticleEntity _articleModelToEntity(NewsArticle model) {
    return NewsArticleEntity(
      id: model.id,
      title: model.title,
      summary: model.summary,
      content: model.content,
      imageUrl: model.imageUrl,
      category: model.category,
      source: model.source,
      publishedAt: model.publishedAt,
      url: model.url,
      isRead: model.isRead,
    );
  }

  @override
  Future<List<CurrencyRateEntity>> getCurrencyRates() async {
    // TODO: Реализовать получение курсов валют
    // Сейчас возвращаем пустой список, так как в NewsLocalDataSource нет этого метода
    // Вам нужно либо:
    // 1. Добавить метод getCurrencyRates() в NewsLocalDataSource
    // 2. Создать отдельный CurrencyRateLocalDataSource
    // 3. Получать данные из API

    return [];

    // Пример, если бы был метод в DataSource:
    // final models = await localDataSource.getCurrencyRates();
    // return models.map(_rateModelToEntity).toList();
  }

  @override
  Future<List<NewsArticleEntity>> getNews() async {
    // Используем Remote DataSource, если он доступен
    if (remoteDataSource != null) {
      try {
        // Получаем топ новости из NewsAPI
        final remoteModels = await remoteDataSource!.getTopHeadlines(
          country: 'us',
          pageSize: 20,
        );
        
        // Сохраняем в локальное хранилище для кеширования
        for (final article in remoteModels) {
          await localDataSource.createNewsArticle(article);
        }
        
        return remoteModels.map(_articleModelToEntity).toList();
      } catch (e) {
        // Если ошибка сети, возвращаем локальные данные
        final localModels = await localDataSource.getAllNewsArticles();
        return localModels.map(_articleModelToEntity).toList();
      }
    }

    // Существующая локальная логика (fallback)
    final models = await localDataSource.getAllNewsArticles();
    return models.map(_articleModelToEntity).toList();
  }

  @override
  Future<NewsArticleEntity?> getNewsById(String id) async {
    final model = await localDataSource.getNewsArticleById(id); // Исправлено с getNewsById() на getNewsArticleById()
    return model != null ? _articleModelToEntity(model) : null;
  }

  @override
  Future<void> markAsRead(String newsId) async {
    await localDataSource.markAsRead(newsId);
  }
}