import '../../repositories/transaction_repository.dart';
import '../../entities/transaction_entity.dart';

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call() {
    return repository.getTransactions();
  }
}

