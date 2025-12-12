import '../../repositories/transaction_repository.dart';
import '../../entities/transaction_entity.dart';

class UpdateTransactionUseCase {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  Future<void> call(TransactionEntity transaction) {
    return repository.updateTransaction(transaction);
  }
}

