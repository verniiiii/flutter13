class TransactionDto {
  final String id;
  final String title;
  final String description;
  final double amount;
  final int createdAtMillis;
  final String type; // 'income' or 'expense'
  final String category;

  TransactionDto({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.createdAtMillis,
    required this.type,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'created_at': createdAtMillis,
      'type': type,
      'category': category,
    };
  }

  factory TransactionDto.fromMap(Map<String, dynamic> map) {
    return TransactionDto(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      createdAtMillis: map['created_at'] as int,
      type: map['type'] as String,
      category: map['category'] as String,
    );
  }
}

