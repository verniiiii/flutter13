enum ContentType {
  quote('Цитата'),
  affirmation('Аффирмация'),
  tip('Совет');

  const ContentType(this.displayName);
  final String displayName;
}

class MotivationContent {
  final String id;
  String text;
  String? author;
  ContentType type;
  String category;
  bool isFavorite;

  MotivationContent({
    required this.id,
    required this.text,
    this.author,
    required this.type,
    required this.category,
    this.isFavorite = false,
  });

  String get typeDisplayName => type.displayName;

  MotivationContent copyWith({
    String? id,
    String? text,
    String? author,
    ContentType? type,
    String? category,
    bool? isFavorite,
  }) {
    return MotivationContent(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      type: type ?? this.type,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}