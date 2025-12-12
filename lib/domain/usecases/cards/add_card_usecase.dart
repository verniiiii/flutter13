import '../../repositories/card_repository.dart';
import '../../entities/card_entity.dart';

class AddCardUseCase {
  final CardRepository repository;

  AddCardUseCase(this.repository);

  Future<void> call(CardEntity card) {
    return repository.addCard(card);
  }
}

