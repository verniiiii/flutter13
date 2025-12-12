enum CardType {
  debit('Дебетовая'),
  credit('Кредитная'),
  prepaid('Предоплаченная');

  const CardType(this.displayName);
  final String displayName;
}

enum CardColor {
  blue('Синий', 0xFF2196F3),
  purple('Фиолетовый', 0xFF9C27B0),
  green('Зеленый', 0xFF4CAF50),
  orange('Оранжевый', 0xFFFF9800),
  red('Красный', 0xFFF44336),
  teal('Бирюзовый', 0xFF009688);

  const CardColor(this.displayName, this.colorValue);
  final String displayName;
  final int colorValue;
}

class CardModel {
  final String id;
  String cardNumber;
  String cardHolderName;
  DateTime expiryDate;
  String cvv;
  CardType cardType;
  String bankName;
  double balance;
  double? creditLimit;
  CardColor cardColor;
  bool isActive;
  DateTime createdAt;

  CardModel({
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

  String get formattedCardNumber {
    if (cardNumber.length != 16) return cardNumber;
    return '${cardNumber.substring(0, 4)} ${cardNumber.substring(4, 8)} ${cardNumber.substring(8, 12)} ${cardNumber.substring(12)}';
  }

  String get maskedCardNumber {
    if (cardNumber.length != 16) return cardNumber;
    return '**** ${cardNumber.substring(12)}';
  }

  String get formattedExpiryDate {
    return '${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year.toString().substring(2)}';
  }

  bool get isCreditCard => cardType == CardType.credit;

  double get availableCredit {
    if (!isCreditCard) return 0.0;
    return (creditLimit ?? 0) - balance;
  }

  CardModel copyWith({
    String? id,
    String? cardNumber,
    String? cardHolderName,
    DateTime? expiryDate,
    String? cvv,
    CardType? cardType,
    String? bankName,
    double? balance,
    double? creditLimit,
    CardColor? cardColor,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CardModel(
      id: id ?? this.id,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      cardType: cardType ?? this.cardType,
      bankName: bankName ?? this.bankName,
      balance: balance ?? this.balance,
      creditLimit: creditLimit ?? this.creditLimit,
      cardColor: cardColor ?? this.cardColor,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}