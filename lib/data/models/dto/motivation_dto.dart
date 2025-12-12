class MotivationDto {
  final String id;
  final String text;
  final String? author;
  final String type; // 'quote', 'affirmation', 'tip'
  final String category;
  final bool isFavorite;

  MotivationDto({
    required this.id,
    required this.text,
    this.author,
    required this.type,
    required this.category,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'type': type,
      'category': category,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory MotivationDto.fromMap(Map<String, dynamic> map) {
    return MotivationDto(
      id: map['id'] as String,
      text: map['text'] as String,
      author: map['author'] as String?,
      type: map['type'] as String,
      category: map['category'] as String,
      isFavorite: (map['is_favorite'] as int) == 1,
    );
  }
}

