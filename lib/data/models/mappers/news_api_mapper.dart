import '../../datasources/remote/dto/news_api_dto.dart';
import '../../../core/models/news_model.dart';

/// Маппер для преобразования NewsAPI DTO в модели приложения
class NewsApiMapper {
  /// Преобразование NewsArticleDto в NewsArticle
  static NewsArticle articleDtoToModel(NewsArticleDto dto) {
    // Генерируем уникальный ID из URL или используем хеш
    final id = dto.url.isNotEmpty 
        ? dto.url.hashCode.toString() 
        : DateTime.now().microsecondsSinceEpoch.toString();

    // Маппинг категории NewsAPI в NewsCategory приложения
    final category = _mapCategoryFromSource(dto.source.name);

    return NewsArticle(
      id: id,
      title: dto.title,
      summary: dto.description ?? dto.title,
      content: dto.content,
      imageUrl: dto.urlToImage,
      category: category,
      source: dto.source.name,
      sourceId: dto.source.id, // Сохраняем ID источника
      publishedAt: dto.publishedAt,
      url: dto.url,
      isRead: false,
    );
  }

  /// Преобразование списка NewsArticleDto в список NewsArticle
  static List<NewsArticle> articlesDtoToModels(List<NewsArticleDto> dtos) {
    return dtos.map((dto) => articleDtoToModel(dto)).toList();
  }

  /// Маппинг категории из источника NewsAPI в NewsCategory приложения
  /// NewsAPI использует: business, technology, sports, health, science, entertainment
  /// Приложение использует: finance, economy, crypto, stocks, personalFinance
  static NewsCategory _mapCategoryFromSource(String sourceName) {
    final lowerSource = sourceName.toLowerCase();
    
    if (lowerSource.contains('crypto') || 
        lowerSource.contains('bitcoin') ||
        lowerSource.contains('blockchain')) {
      return NewsCategory.crypto;
    }
    
    if (lowerSource.contains('stock') || 
        lowerSource.contains('trading') ||
        lowerSource.contains('market') ||
        lowerSource.contains('nasdaq') ||
        lowerSource.contains('nyse')) {
      return NewsCategory.stocks;
    }
    
    if (lowerSource.contains('personal') || 
        lowerSource.contains('saving') ||
        lowerSource.contains('budget')) {
      return NewsCategory.personalFinance;
    }
    
    if (lowerSource.contains('economy') || 
        lowerSource.contains('economic') ||
        lowerSource.contains('gdp')) {
      return NewsCategory.economy;
    }
    
    // По умолчанию возвращаем finance
    return NewsCategory.finance;
  }

  /// Маппинг категории NewsAPI в NewsCategory приложения
  static NewsCategory mapCategoryFromApiCategory(String apiCategory) {
    switch (apiCategory.toLowerCase()) {
      case 'business':
        return NewsCategory.finance;
      case 'technology':
      case 'tech':
        // Технологии маппятся в finance, так как нет отдельной категории
        return NewsCategory.finance;
      default:
        return NewsCategory.finance;
    }
  }
}

