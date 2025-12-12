import 'package:prac13/core/constants/categories.dart';

class TransactionEntity {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime createdAt;
  final TransactionType type;
  final String category;

  TransactionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.createdAt,
    required this.type,
    required this.category,
  });

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
}

