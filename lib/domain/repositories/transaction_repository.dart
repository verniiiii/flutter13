import '../entities/transaction_entity.dart';
import 'package:prac13/core/constants/categories.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<TransactionEntity?> getTransactionById(String id);
  Future<void> addTransaction(TransactionEntity transaction);
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionEntity>> getTransactionsByCategory(String category);
  Future<List<TransactionEntity>> getTransactionsByType(TransactionType type);
}

