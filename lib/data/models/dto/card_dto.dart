class CardDto {
  final String id;
  final String cardNumber;
  final String cardHolderName;
  final int expiryDateMillis;
  final String cvv;
  final String cardType; // 'debit', 'credit', 'prepaid'
  final String bankName;
  final double balance;
  final double? creditLimit;
  final String cardColor; // 'blue', 'purple', etc.
  final bool isActive;
  final int createdAtMillis;

  CardDto({
    required this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDateMillis,
    required this.cvv,
    required this.cardType,
    required this.bankName,
    required this.balance,
    this.creditLimit,
    required this.cardColor,
    this.isActive = true,
    required this.createdAtMillis,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_number': cardNumber,
      'card_holder_name': cardHolderName,
      'expiry_date': expiryDateMillis,
      'cvv': cvv,
      'card_type': cardType,
      'bank_name': bankName,
      'balance': balance,
      'credit_limit': creditLimit,
      'card_color': cardColor,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAtMillis,
    };
  }

  factory CardDto.fromMap(Map<String, dynamic> map) {
    return CardDto(
      id: map['id'] as String,
      cardNumber: map['card_number'] as String,
      cardHolderName: map['card_holder_name'] as String,
      expiryDateMillis: map['expiry_date'] as int,
      cvv: map['cvv'] as String,
      cardType: map['card_type'] as String,
      bankName: map['bank_name'] as String,
      balance: map['balance'] as double,
      creditLimit: map['credit_limit'] as double?,
      cardColor: map['card_color'] as String,
      isActive: (map['is_active'] as int) == 1,
      createdAtMillis: map['created_at'] as int,
    );
  }
}

