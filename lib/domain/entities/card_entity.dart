import 'package:prac13/core/models/card_model.dart';

class CardEntity {
  final String id;
  final String cardNumber;
  final String cardHolderName;
  final DateTime expiryDate;
  final String cvv;
  final CardType cardType;
  final String bankName;
  final double balance;
  final double? creditLimit;
  final CardColor cardColor;
  final bool isActive;
  final DateTime createdAt;

  CardEntity({
    required this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvv,
    required this.cardType,
    required this.bankName,
    required this.balance,
    this.creditLimit,
    required this.cardColor,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isCreditCard => cardType == CardType.credit;
  double get availableCredit {
    if (!isCreditCard) return 0.0;
    return (creditLimit ?? 0) - balance;
  }
}

