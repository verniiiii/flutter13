import 'package:prac13/core/models/news_model.dart';
import 'package:prac13/data/models/dto/news_dto.dart';
import 'package:prac13/domain/entities/news_entity.dart';

class NewsMapper {
  static NewsArticleDto toDto(NewsArticle model) {
    return NewsArticleDto(
      id: model.id,
      title: model.title,
      summary: model.summary,
      content: model.content,
      imageUrl: model.imageUrl,
      category: _newsCategoryToString(model.category),
      source: model.source,
      publishedAtMillis: model.publishedAt.millisecondsSinceEpoch,
      url: model.url,
      isRead: model.isRead,
    );
  }

  static NewsArticle fromDto(NewsArticleDto dto) {
    return NewsArticle(
      id: dto.id,
      title: dto.title,
      summary: dto.summary,
      content: dto.content,
      imageUrl: dto.imageUrl,
      category: _stringToNewsCategory(dto.category),
      source: dto.source,
      publishedAt: DateTime.fromMillisecondsSinceEpoch(dto.publishedAtMillis),
      url: dto.url,
      isRead: dto.isRead,
    );
  }

  static NewsArticleEntity toEntity(NewsArticle model) {
    return NewsArticleEntity(
      id: model.id,
      title: model.title,
      summary: model.summary,
      content: model.content,
      imageUrl: model.imageUrl,
      category: model.category,
      source: model.source,
      sourceId: model.sourceId,
      publishedAt: model.publishedAt,
      url: model.url,
      isRead: model.isRead,
    );
  }

  static NewsArticle fromEntity(NewsArticleEntity entity) {
    return NewsArticle(
      id: entity.id,
      title: entity.title,
      summary: entity.summary,
      content: entity.content,
      imageUrl: entity.imageUrl,
      category: entity.category,
      source: entity.source,
      sourceId: entity.sourceId,
      publishedAt: entity.publishedAt,
      url: entity.url,
      isRead: entity.isRead,
    );
  }

  static String _newsCategoryToString(NewsCategory category) {
    switch (category) {
      case NewsCategory.finance:
        return 'finance';
      case NewsCategory.economy:
        return 'economy';
      case NewsCategory.crypto:
        return 'crypto';
      case NewsCategory.stocks:
        return 'stocks';
      case NewsCategory.personalFinance:
        return 'personal_finance';
    }
  }

  static NewsCategory _stringToNewsCategory(String str) {
    switch (str) {
      case 'finance':
        return NewsCategory.finance;
      case 'economy':
        return NewsCategory.economy;
      case 'crypto':
        return NewsCategory.crypto;
      case 'stocks':
        return NewsCategory.stocks;
      case 'personal_finance':
        return NewsCategory.personalFinance;
      default:
        return NewsCategory.finance;
    }
  }
}

