import 'package:prac13/core/models/motivation_model.dart';

class MotivationContentEntity {
  final String id;
  final String text;
  final String? author;
  final ContentType type;
  final String category;
  final bool isFavorite;

  MotivationContentEntity({
    required this.id,
    required this.text,
    this.author,
    required this.type,
    required this.category,
    this.isFavorite = false,
  });
}

