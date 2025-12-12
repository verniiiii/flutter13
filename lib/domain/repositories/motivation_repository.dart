import '../entities/motivation_entity.dart';
import 'package:prac13/core/models/motivation_model.dart';

abstract class MotivationRepository {
  Future<MotivationContentEntity> getRandomContent(ContentType type);
  Future<List<MotivationContentEntity>> getFavoriteContent();
  Future<void> toggleFavorite(String id);
}

