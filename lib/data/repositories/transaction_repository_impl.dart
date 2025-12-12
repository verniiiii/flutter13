import '../../domain/repositories/transaction_repository.dart';
import '../../domain/entities/transaction_entity.dart';
import '../datasources/local/transaction_local_datasource.dart';
import '../../core/models/transaction_model.dart';
import '../../core/constants/categories.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl(this.localDataSource);

  TransactionEntity _modelToEntity(Transaction model) {
    return TransactionEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      amount: model.amount,
      createdAt: model.createdAt,
      type: model.type,
      category: model.category,
    );
  }

  Transaction _entityToModel(TransactionEntity entity) {
    return Transaction(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      amount: entity.amount,
      createdAt: entity.createdAt,
      type: entity.type,
      category: entity.category,
    );
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final models = await localDataSource.getAllTransactions();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    final model = await localDataSource.getTransactionById(id);
    return model != null ? _modelToEntity(model) : null;
  }

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    await localDataSource.createTransaction(_entityToModel(transaction));
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    await localDataSource.updateTransaction(_entityToModel(transaction));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await localDataSource.deleteTransaction(id);
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCategory(String category) async {
    final all = await getTransactions();
    return all.where((t) => t.category == category).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByType(TransactionType type) async {
    final all = await getTransactions();
    return all.where((t) => t.type == type).toList();
  }
}

