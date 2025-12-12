import 'package:flutter/foundation.dart';
import 'package:prac13/core/models/transaction_model.dart';
import 'package:prac13/core/constants/categories.dart';

class EditTransactionStore with ChangeNotifier {
  List<Transaction> _transactions = [];

  String _title = '';
  String _description = '';
  double _amount = 0.0;
  TransactionType _type = TransactionType.expense;
  String _selectedCategory = 'Продукты';

  // Геттеры
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  String get title => _title;
  String get description => _description;
  double get amount => _amount;
  TransactionType get type => _type;
  String get selectedCategory => _selectedCategory;

  // Сеттеры с уведомлением
  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setAmount(double value) {
    _amount = value;
    notifyListeners();
  }

  void setType(TransactionType value) {
    _type = value;
    notifyListeners();
  }

  void setSelectedCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  // Инициализация данными из существующей транзакции
  void initializeWithTransaction(Transaction transaction) {
    _title = transaction.title;
    _description = transaction.description;
    _amount = transaction.amount;
    _type = transaction.type;
    _selectedCategory = transaction.category;
    notifyListeners();
  }

  // Инициализация для новой транзакции
  void initializeForNewTransaction() {
    _title = '';
    _description = '';
    _amount = 0.0;
    _type = TransactionType.expense;
    _selectedCategory = 'Продукты';
    notifyListeners();
  }

  // Методы для работы с транзакциями

  void setTransactions(List<Transaction> transactions) {
    _transactions = List.from(transactions);
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateTransaction(String id) {
    final index = _transactions.indexWhere((transaction) => transaction.id == id);
    if (index != -1) {
      _transactions[index] = _transactions[index].copyWith(
        title: _title,
        description: _description,
        amount: _amount,
        type: _type,
        category: _selectedCategory,
      );
      notifyListeners();
    }
  }

  void createTransaction() {
    final newTransaction = Transaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title,
      description: _description,
      amount: _amount,
      createdAt: DateTime.now(),
      type: _type,
      category: _selectedCategory,
    );

    _transactions.add(newTransaction);

    // Сбрасываем форму
    initializeForNewTransaction();

    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
  }

  void resetForm() {
    _title = '';
    _description = '';
    _amount = 0.0;
    _type = TransactionType.expense;
    _selectedCategory = 'Продукты';
    notifyListeners();
  }

  // Валидация формы
  bool get isFormValid {
    return _title.trim().isNotEmpty && _amount > 0;
  }

  String? get titleError {
    if (_title.trim().isEmpty) {
      return 'Введите название';
    }
    return null;
  }

  String? get amountError {
    if (_amount <= 0) {
      return 'Сумма должна быть больше 0';
    }
    return null;
  }

  String? get categoryError {
    if (_selectedCategory.isEmpty) {
      return 'Выберите категорию';
    }
    return null;
  }

  // Проверка, изменилась ли форма по сравнению с оригинальной транзакцией
  bool hasChanges(Transaction? originalTransaction) {
    if (originalTransaction == null) return true;

    return _title != originalTransaction.title ||
        _description != originalTransaction.description ||
        _amount != originalTransaction.amount ||
        _type != originalTransaction.type ||
        _selectedCategory != originalTransaction.category;
  }

  // Копия данных формы для предпросмотра
  Transaction get formDataAsTransaction {
    return Transaction(
      id: 'preview',
      title: _title,
      description: _description,
      amount: _amount,
      createdAt: DateTime.now(),
      type: _type,
      category: _selectedCategory,
    );
  }

  // Получить категории по типу транзакции
  List<String> getCategoriesForType(TransactionType type) {
    // Здесь можно возвращать разные списки категорий для доходов и расходов
    // Пример категорий для расходов
    final expenseCategories = [
      'Продукты',
      'Транспорт',
      'Жилье',
      'Развлечения',
      'Здоровье',
      'Одежда',
      'Образование',
      'Подарки',
      'Другое',
    ];

    // Пример категорий для доходов
    final incomeCategories = [
      'Зарплата',
      'Фриланс',
      'Инвестиции',
      'Подарок',
      'Возврат долга',
      'Прочее',
    ];

    return type == TransactionType.expense ? expenseCategories : incomeCategories;
  }

  // Автоматическое определение категории на основе названия
  void autoDetectCategory() {
    final titleLower = _title.toLowerCase();

    // Простые правила для определения категории
    if (titleLower.contains('магазин') ||
        titleLower.contains('продукт') ||
        titleLower.contains('супермаркет')) {
      _selectedCategory = 'Продукты';
    } else if (titleLower.contains('бензин') ||
        titleLower.contains('заправка') ||
        titleLower.contains('метро') ||
        titleLower.contains('такси')) {
      _selectedCategory = 'Транспорт';
    } else if (titleLower.contains('коммунал') ||
        titleLower.contains('аренд') ||
        titleLower.contains('квартир')) {
      _selectedCategory = 'Жилье';
    } else if (titleLower.contains('кафе') ||
        titleLower.contains('ресторан') ||
        titleLower.contains('кино') ||
        titleLower.contains('развлеч')) {
      _selectedCategory = 'Развлечения';
    } else if (titleLower.contains('зарплат') ||
        titleLower.contains('оклад') ||
        titleLower.contains('доход')) {
      _type = TransactionType.income;
      _selectedCategory = 'Зарплата';
    }

    notifyListeners();
  }

  // Экспорт данных формы в Map
  Map<String, dynamic> toMap() {
    return {
      'title': _title,
      'description': _description,
      'amount': _amount,
      'type': _type == TransactionType.expense ? 'expense' : 'income',
      'category': _selectedCategory,
    };
  }

  // Импорт данных из Map
  void fromMap(Map<String, dynamic> map) {
    _title = map['title'] ?? '';
    _description = map['description'] ?? '';
    _amount = (map['amount'] ?? 0.0).toDouble();
    _type = (map['type'] == 'income') ? TransactionType.income : TransactionType.expense;
    _selectedCategory = map['category'] ?? 'Продукты';
    notifyListeners();
  }
}