import 'package:prac13/core/models/motivation_model.dart';
import 'package:prac13/data/models/dto/motivation_dto.dart';
import 'package:prac13/domain/entities/motivation_entity.dart';

class MotivationMapper {
  static MotivationDto toDto(MotivationContent model) {
    return MotivationDto(
      id: model.id,
      text: model.text,
      author: model.author,
      type: _contentTypeToString(model.type),
      category: model.category,
      isFavorite: model.isFavorite,
    );
  }

  static MotivationContent fromDto(MotivationDto dto) {
    return MotivationContent(
      id: dto.id,
      text: dto.text,
      author: dto.author,
      type: _stringToContentType(dto.type),
      category: dto.category,
      isFavorite: dto.isFavorite,
    );
  }

  static MotivationContentEntity toEntity(MotivationContent model) {
    return MotivationContentEntity(
      id: model.id,
      text: model.text,
      author: model.author,
      type: model.type,
      category: model.category,
      isFavorite: model.isFavorite,
    );
  }

  static MotivationContent fromEntity(MotivationContentEntity entity) {
    return MotivationContent(
      id: entity.id,
      text: entity.text,
      author: entity.author,
      type: entity.type,
      category: entity.category,
      isFavorite: entity.isFavorite,
    );
  }

  static String _contentTypeToString(ContentType type) {
    switch (type) {
      case ContentType.quote:
        return 'quote';
      case ContentType.affirmation:
        return 'affirmation';
      case ContentType.tip:
        return 'tip';
    }
  }

  static ContentType _stringToContentType(String str) {
    switch (str) {
      case 'quote':
        return ContentType.quote;
      case 'affirmation':
        return ContentType.affirmation;
      case 'tip':
        return ContentType.tip;
      default:
        return ContentType.quote;
    }
  }
}

