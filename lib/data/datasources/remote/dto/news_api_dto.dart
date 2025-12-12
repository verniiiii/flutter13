/// DTO модели для NewsAPI.org с ручной сериализацией

/// DTO для источника новостей
class SourceDto {
  final String? id;
  final String name;

  SourceDto({
    this.id,
    required this.name,
  });

  factory SourceDto.fromJson(Map<String, dynamic> json) {
    return SourceDto(
      id: json['id'] as String?,
      name: json['name'] ?? 'Неизвестный источник',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }
}

/// DTO для статьи новостей
class NewsArticleDto {
  final SourceDto source;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String? content;

  NewsArticleDto({
    required this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
  });

  factory NewsArticleDto.fromJson(Map<String, dynamic> json) {
    return NewsArticleDto(
      source: SourceDto.fromJson(json['source'] as Map<String, dynamic>? ?? {}),
      author: json['author'] as String?,
      title: json['title'] ?? 'Без названия',
      description: json['description'] as String?,
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] as String?,
      publishedAt: _parseDateTime(json['publishedAt']),
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.toJson(),
      if (author != null) 'author': author,
      'title': title,
      if (description != null) 'description': description,
      'url': url,
      if (urlToImage != null) 'urlToImage': urlToImage,
      'publishedAt': publishedAt.toIso8601String(),
      if (content != null) 'content': content,
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}

/// DTO для ответа NewsAPI
class NewsResponseDto {
  final String status;
  final int totalResults;
  final List<NewsArticleDto> articles;

  NewsResponseDto({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponseDto.fromJson(Map<String, dynamic> json) {
    final articlesData = json['articles'] as List<dynamic>? ?? [];
    return NewsResponseDto(
      status: json['status'] ?? 'error',
      totalResults: json['totalResults'] ?? 0,
      articles: articlesData
          .map((article) => NewsArticleDto.fromJson(article as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'totalResults': totalResults,
      'articles': articles.map((article) => article.toJson()).toList(),
    };
  }
}

/// DTO для источника новостей (из эндпоинта /sources)
class NewsSourceDto {
  final String id;
  final String name;
  final String? description;
  final String url;
  final String category;
  final String language;
  final String country;

  NewsSourceDto({
    required this.id,
    required this.name,
    this.description,
    required this.url,
    required this.category,
    required this.language,
    required this.country,
  });

  factory NewsSourceDto.fromJson(Map<String, dynamic> json) {
    return NewsSourceDto(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Неизвестный источник',
      description: json['description'] as String?,
      url: json['url'] ?? '',
      category: json['category'] ?? 'general',
      language: json['language'] ?? 'en',
      country: json['country'] ?? 'us',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'url': url,
      'category': category,
      'language': language,
      'country': country,
    };
  }
}

/// DTO для ответа списка источников
class NewsSourcesResponseDto {
  final String status;
  final List<NewsSourceDto> sources;

  NewsSourcesResponseDto({
    required this.status,
    required this.sources,
  });

  factory NewsSourcesResponseDto.fromJson(Map<String, dynamic> json) {
    final sourcesData = json['sources'] as List<dynamic>? ?? [];
    return NewsSourcesResponseDto(
      status: json['status'] ?? 'error',
      sources: sourcesData
          .map((source) => NewsSourceDto.fromJson(source as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'sources': sources.map((source) => source.toJson()).toList(),
    };
  }
}

