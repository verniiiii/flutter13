enum TransactionType {
  income('Доход'),
  expense('Расход');

  const TransactionType(this.displayName);
  final String displayName;
}

class TransactionCategories {
  static const List<String> incomeCategories = [
    'Зарплата',
    'Фриланс',
    'Инвестиции',
    'Подарки',
    'Прочее'
  ];

  static const List<String> expenseCategories = [
    'Продукты',
    'Транспорт',
    'Развлечения',
    'Жилье',
    'Здоровье',
    'Одежда',
    'Прочее'
  ];

  static List<String> getCategoriesForType(TransactionType type) {
    return type == TransactionType.income ? incomeCategories : expenseCategories;
  }

  static String getDefaultCategoryForType(TransactionType type) {
    return type == TransactionType.income ? incomeCategories.first : expenseCategories.first;
  }
}