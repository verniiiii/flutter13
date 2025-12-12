import '../../repositories/card_repository.dart';
import '../../entities/card_entity.dart';

class GetCardsUseCase {
  final CardRepository repository;

  GetCardsUseCase(this.repository);

  Future<List<CardEntity>> call() {
    return repository.getCards();
  }
}

