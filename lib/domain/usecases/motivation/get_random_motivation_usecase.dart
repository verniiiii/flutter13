import '../../repositories/motivation_repository.dart';
import '../../entities/motivation_entity.dart';
import 'package:prac13/core/models/motivation_model.dart';

class GetRandomMotivationUseCase {
  final MotivationRepository repository;

  GetRandomMotivationUseCase(this.repository);

  Future<MotivationContentEntity> call(ContentType type) {
    return repository.getRandomContent(type);
  }
}

