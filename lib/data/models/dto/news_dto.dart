class NewsArticleDto {
  final String id;
  final String title;
  final String summary;
  final String? content;
  final String? imageUrl;
  final String category; // 'finance', 'economy', etc.
  final String source;
  final int publishedAtMillis;
  final String? url;
  final bool isRead;

  NewsArticleDto({
    required this.id,
    required this.title,
    required this.summary,
    this.content,
    this.imageUrl,
    required this.category,
    required this.source,
    required this.publishedAtMillis,
    this.url,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'image_url': imageUrl,
      'category': category,
      'source': source,
      'published_at': publishedAtMillis,
      'url': url,
      'is_read': isRead ? 1 : 0,
    };
  }

  factory NewsArticleDto.fromMap(Map<String, dynamic> map) {
    return NewsArticleDto(
      id: map['id'] as String,
      title: map['title'] as String,
      summary: map['summary'] as String,
      content: map['content'] as String?,
      imageUrl: map['image_url'] as String?,
      category: map['category'] as String,
      source: map['source'] as String,
      publishedAtMillis: map['published_at'] as int,
      url: map['url'] as String?,
      isRead: (map['is_read'] as int) == 1,
    );
  }
}

