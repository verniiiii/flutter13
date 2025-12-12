import '../../repositories/transaction_repository.dart';
import '../../entities/transaction_entity.dart';

class AddTransactionUseCase {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  Future<void> call(TransactionEntity transaction) {
    return repository.addTransaction(transaction);
  }
}

