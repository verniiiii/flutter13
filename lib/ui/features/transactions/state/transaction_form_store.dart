import 'package:flutter/foundation.dart';
import 'package:prac13/core/models/transaction_model.dart';
import 'package:prac13/core/constants/categories.dart';

class TransactionFormStore with ChangeNotifier {
  List<Transaction> _transactions = [];

  String _title = '';
  String _description = '';
  double _amount = 0.0;
  TransactionType _type = TransactionType.expense;
  String _selectedCategory = 'Продукты';
  bool _isSubmitting = false;
  String _errorMessage = '';

  // Геттеры
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  String get title => _title;
  String get description => _description;
  double get amount => _amount;
  TransactionType get type => _type;
  String get selectedCategory => _selectedCategory;
  bool get isSubmitting => _isSubmitting;
  String get errorMessage => _errorMessage;

  // Проверка валидности формы
  bool get isFormValid => _title.trim().isNotEmpty && _amount > 0;

  bool get hasTitleError => _title.trim().isEmpty;
  bool get hasAmountError => _amount <= 0;
  bool get hasCategoryError => _selectedCategory.isEmpty;

  String? get titleErrorText => hasTitleError ? 'Введите название транзакции' : null;
  String? get amountErrorText => hasAmountError ? 'Сумма должна быть больше 0' : null;
  String? get categoryErrorText => hasCategoryError ? 'Выберите категорию' : null;

  // Сеттеры с уведомлением
  void setTitle(String value) {
    _title = value;
    _errorMessage = ''; // Сбрасываем ошибку при изменении
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setAmount(double value) {
    _amount = value;
    _errorMessage = ''; // Сбрасываем ошибку при изменении
    notifyListeners();
  }

  void setAmountFromString(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    setAmount(parsed);
  }

  void setType(TransactionType value) {
    _type = value;

    // При смене типа можно сбросить категорию на первую из соответствующего списка
    if (_type == TransactionType.income &&
        !_getIncomeCategories().contains(_selectedCategory)) {
      _selectedCategory = _getIncomeCategories().firstOrNull ?? 'Зарплата';
    } else if (_type == TransactionType.expense &&
        !_getExpenseCategories().contains(_selectedCategory)) {
      _selectedCategory = _getExpenseCategories().firstOrNull ?? 'Продукты';
    }

    notifyListeners();
  }

  void setSelectedCategory(String value) {
    _selectedCategory = value;
    _errorMessage = ''; // Сбрасываем ошибку при изменении
    notifyListeners();
  }

  // Методы для работы с данными
  void setTransactions(List<Transaction> transactions) {
    _transactions = List.from(transactions);
    notifyListeners();
  }

  void clearForm() {
    _title = '';
    _description = '';
    _amount = 0.0;
    _type = TransactionType.expense;
    _selectedCategory = 'Продукты';
    _errorMessage = '';
    notifyListeners();
  }

  void initializeForEdit(Transaction transaction) {
    _title = transaction.title;
    _description = transaction.description;
    _amount = transaction.amount;
    _type = transaction.type;
    _selectedCategory = transaction.category;
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> addTransaction() async {
    if (!isFormValid) {
      _errorMessage = 'Заполните все обязательные поля';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Имитация задержки сети
      await Future.delayed(const Duration(milliseconds: 500));

      final newTransaction = Transaction(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _title.trim(),
        description: _description.trim(),
        amount: _amount,
        createdAt: DateTime.now(),
        type: _type,
        category: _selectedCategory,
      );

      _transactions.add(newTransaction);

      // Очищаем форму после успешного добавления
      clearForm();

      _isSubmitting = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = 'Ошибка при добавлении транзакции: ${e.toString()}';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(String id) async {
    if (!isFormValid) {
      _errorMessage = 'Заполните все обязательные поля';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Имитация задержки сети
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _transactions.indexWhere((transaction) => transaction.id == id);
      if (index != -1) {
        final updatedTransaction = _transactions[index].copyWith(
          title: _title.trim(),
          description: _description.trim(),
          amount: _amount,
          type: _type,
          category: _selectedCategory,
        );

        _transactions[index] = updatedTransaction;

        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Транзакция не найдена';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

    } catch (e) {
      _errorMessage = 'Ошибка при обновлении транзакции: ${e.toString()}';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // Автоматическое определение категории на основе названия
  void autoDetectCategory() {
    final titleLower = _title.toLowerCase();

    if (_type == TransactionType.expense) {
      if (titleLower.contains('магазин') ||
          titleLower.contains('продукт') ||
          titleLower.contains('супермаркет') ||
          titleLower.contains('еда') ||
          titleLower.contains('продуктов')) {
        _selectedCategory = 'Продукты';
      } else if (titleLower.contains('бензин') ||
          titleLower.contains('заправка') ||
          titleLower.contains('метро') ||
          titleLower.contains('такси') ||
          titleLower.contains('транспорт')) {
        _selectedCategory = 'Транспорт';
      } else if (titleLower.contains('коммунал') ||
          titleLower.contains('аренд') ||
          titleLower.contains('квартир') ||
          titleLower.contains('жилье')) {
        _selectedCategory = 'Жилье';
      } else if (titleLower.contains('кафе') ||
          titleLower.contains('ресторан') ||
          titleLower.contains('кино') ||
          titleLower.contains('развлеч') ||
          titleLower.contains('отдых')) {
        _selectedCategory = 'Развлечения';
      } else if (titleLower.contains('аптека') ||
          titleLower.contains('врач') ||
          titleLower.contains('больница') ||
          titleLower.contains('здоровье')) {
        _selectedCategory = 'Здоровье';
      }
    } else {
      if (titleLower.contains('зарплат') ||
          titleLower.contains('оклад') ||
          titleLower.contains('доход') ||
          titleLower.contains('заработн')) {
        _selectedCategory = 'Зарплата';
      } else if (titleLower.contains('фриланс') ||
          titleLower.contains('проект') ||
          titleLower.contains('подработка')) {
        _selectedCategory = 'Фриланс';
      } else if (titleLower.contains('инвестиц') ||
          titleLower.contains('дивиденд') ||
          titleLower.contains('акции') ||
          titleLower.contains('процент')) {
        _selectedCategory = 'Инвестиции';
      }
    }

    notifyListeners();
  }

  // Предварительный просмотр транзакции
  Transaction get formPreview {
    return Transaction(
      id: 'preview',
      title: _title.isEmpty ? 'Название транзакции' : _title,
      description: _description,
      amount: _amount,
      createdAt: DateTime.now(),
      type: _type,
      category: _selectedCategory,
    );
  }

  // Получение списков категорий
  List<String> getAvailableCategories() {
    return _type == TransactionType.expense
        ? _getExpenseCategories()
        : _getIncomeCategories();
  }

  List<String> _getExpenseCategories() {
    return [
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
  }

  List<String> _getIncomeCategories() {
    return [
      'Зарплата',
      'Фриланс',
      'Инвестиции',
      'Подарок',
      'Возврат долга',
      'Прочее',
    ];
  }

  // Быстрая установка суммы
  void quickSetAmount(double value) {
    _amount = value;
    notifyListeners();
  }

  void quickSetAmountByPercentage(double percentage) {
    if (percentage > 0 && percentage <= 100) {
      // Здесь можно добавить логику для расчета процента от чего-либо
      // Например, от последней зарплаты или среднего расхода
      _amount = percentage;
      notifyListeners();
    }
  }

  // Проверка, есть ли изменения по сравнению с оригинальной транзакцией
  bool hasChanges(Transaction? original) {
    if (original == null) return true;

    return _title != original.title ||
        _description != original.description ||
        _amount != original.amount ||
        _type != original.type ||
        _selectedCategory != original.category;
  }

  // Копирование данных из другой транзакции (для повторяющихся расходов)
  void copyFromTransaction(Transaction transaction) {
    _title = transaction.title;
    _description = transaction.description;
    _amount = transaction.amount;
    _type = transaction.type;
    _selectedCategory = transaction.category;
    notifyListeners();
  }

  // Сохранение шаблона
  Map<String, dynamic> saveAsTemplate(String templateName) {
    return {
      'name': templateName,
      'title': _title,
      'description': _description,
      'amount': _amount,
      'type': _type == TransactionType.income ? 'income' : 'expense',
      'category': _selectedCategory,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Загрузка из шаблона
  void loadFromTemplate(Map<String, dynamic> template) {
    _title = template['title'] ?? '';
    _description = template['description'] ?? '';
    _amount = (template['amount'] ?? 0.0).toDouble();
    _type = (template['type'] == 'income') ? TransactionType.income : TransactionType.expense;
    _selectedCategory = template['category'] ?? 'Продукты';
    notifyListeners();
  }

  // Сброс ошибки
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Получение данных формы в виде Map
  Map<String, dynamic> toMap() {
    return {
      'title': _title,
      'description': _description,
      'amount': _amount,
      'type': _type == TransactionType.income ? 'income' : 'expense',
      'category': _selectedCategory,
    };
  }

  // Загрузка данных из Map
  void fromMap(Map<String, dynamic> map) {
    _title = map['title'] ?? '';
    _description = map['description'] ?? '';
    _amount = (map['amount'] ?? 0.0).toDouble();
    _type = (map['type'] == 'income') ? TransactionType.income : TransactionType.expense;
    _selectedCategory = map['category'] ?? 'Продукты';
    notifyListeners();
  }
}