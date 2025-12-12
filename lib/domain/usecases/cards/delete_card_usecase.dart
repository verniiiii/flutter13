import '../../repositories/card_repository.dart';

class DeleteCardUseCase {
  final CardRepository repository;

  DeleteCardUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteCard(id);
  }
}

