import '../../domain/repositories/motivation_repository.dart';
import '../../domain/entities/motivation_entity.dart';
import '../datasources/local/motivation_local_datasource.dart';
import '../../core/models/motivation_model.dart';
import 'dart:math';

class MotivationRepositoryImpl implements MotivationRepository {
  final MotivationLocalDataSource localDataSource;

  MotivationRepositoryImpl(this.localDataSource);

  MotivationContentEntity _modelToEntity(MotivationContent model) {
    return MotivationContentEntity(
      id: model.id,
      text: model.text,
      author: model.author,
      type: model.type,
      category: model.category,
      isFavorite: model.isFavorite,
    );
  }

  @override
  Future<MotivationContentEntity> getRandomContent(ContentType type) async {
    final models = await localDataSource.getMotivationsByType(type);

    if (models.isEmpty) {
      throw Exception('No motivation content found for type: $type');
    }

    final randomIndex = Random().nextInt(models.length);
    return _modelToEntity(models[randomIndex]);
  }

  @override
  Future<List<MotivationContentEntity>> getFavoriteContent() async {
    final models = await localDataSource.getFavoriteMotivations(); // Исправлено с getFavorites() на getFavoriteMotivations()
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await localDataSource.toggleFavorite(id);
  }
}