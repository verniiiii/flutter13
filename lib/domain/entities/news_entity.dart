import 'package:prac13/core/models/news_model.dart';

class CurrencyRateEntity {
  final String code;
  final String name;
  final double rate;
  final double change;
  final double changePercent;
  final String symbol;

  CurrencyRateEntity({
    required this.code,
    required this.name,
    required this.rate,
    required this.change,
    required this.changePercent,
    required this.symbol,
  });

  bool get isPositive => change >= 0;
}

class NewsArticleEntity {
  final String id;
  final String title;
  final String summary;
  final String? content;
  final String? imageUrl;
  final NewsCategory category;
  final String source;
  final DateTime publishedAt;
  final String? url;
  final bool isRead;

  NewsArticleEntity({
    required this.id,
    required this.title,
    required this.summary,
    this.content,
    this.imageUrl,
    required this.category,
    required this.source,
    required this.publishedAt,
    this.url,
    this.isRead = false,
  });
}

