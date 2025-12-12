enum NewsCategory {
  finance('Финансы'),
  economy('Экономика'),
  crypto('Криптовалюты'),
  stocks('Акции'),
  personalFinance('Личные финансы');

  const NewsCategory(this.displayName);
  final String displayName;
}

class CurrencyRate {
  final String code;
  String name;
  double rate;
  double change;
  double changePercent;
  String symbol;

  CurrencyRate({
    required this.code,
    required this.name,
    required this.rate,
    required this.change,
    required this.changePercent,
    required this.symbol,
  });

  bool get isPositive => change >= 0;

  String get categoryDisplayName => 'Валюты'; // Статическая категория для валют

  CurrencyRate copyWith({
    String? code,
    String? name,
    double? rate,
    double? change,
    double? changePercent,
    String? symbol,
  }) {
    return CurrencyRate(
      code: code ?? this.code,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      symbol: symbol ?? this.symbol,
    );
  }
}

class NewsArticle {
  final String id;
  String title;
  String summary;
  String? content;
  String? imageUrl;
  NewsCategory category;
  String source;
  String? sourceId; // ID источника из NewsAPI
  DateTime publishedAt;
  String? url;
  bool isRead;

  NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    this.content,
    this.imageUrl,
    required this.category,
    required this.source,
    this.sourceId,
    required this.publishedAt,
    this.url,
    this.isRead = false,
  });

  String get categoryDisplayName => category.displayName;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      return '${publishedAt.day}.${publishedAt.month}.${publishedAt.year}';
    }
  }

  NewsArticle copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? imageUrl,
    NewsCategory? category,
    String? source,
    String? sourceId,
    DateTime? publishedAt,
    String? url,
    bool? isRead,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      publishedAt: publishedAt ?? this.publishedAt,
      url: url ?? this.url,
      isRead: isRead ?? this.isRead,
    );
  }
}