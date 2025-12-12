import 'package:prac13/core/constants/categories.dart';
import 'package:prac13/core/models/transaction_model.dart';
import 'package:prac13/data/models/dto/transaction_dto.dart';
import 'package:prac13/domain/entities/transaction_entity.dart';

class TransactionMapper {
  static TransactionDto toDto(Transaction model) {
    return TransactionDto(
      id: model.id,
      title: model.title,
      description: model.description,
      amount: model.amount,
      createdAtMillis: model.createdAt.millisecondsSinceEpoch,
      type: model.type == TransactionType.income ? 'income' : 'expense',
      category: model.category,
    );
  }

  static Transaction fromDto(TransactionDto dto) {
    return Transaction(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      amount: dto.amount,
      createdAt: DateTime.fromMillisecondsSinceEpoch(dto.createdAtMillis),
      type: dto.type == 'income' ? TransactionType.income : TransactionType.expense,
      category: dto.category,
    );
  }

  static TransactionEntity toEntity(Transaction model) {
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

  static Transaction fromEntity(TransactionEntity entity) {
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
}

