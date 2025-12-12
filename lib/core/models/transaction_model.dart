import 'package:prac13/core/constants/categories.dart';

class Transaction {
  final String id;
  String title;
  String description;
  double amount;
  DateTime createdAt;
  TransactionType type;
  String category;

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.createdAt,
    required this.type,
    required this.category,
  });

  String get typeDisplayName => type.displayName;

  bool get isExpense => type == TransactionType.expense;

  bool get isIncome => type == TransactionType.income;

  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.year}';
  }

  String get formattedAmount {
    return '${amount.toStringAsFixed(2)} ₽';
  }

  Transaction copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    DateTime? createdAt,
    TransactionType? type,
    String? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      category: category ?? this.category,
    );
  }
}