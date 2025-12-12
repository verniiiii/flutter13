import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prac13/core/models/transaction_model.dart';
import 'package:prac13/core/constants/categories.dart';

class TransactionsListStore with ChangeNotifier {
  List<Transaction> _transactions = [];
  String _searchQuery = '';
  String _selectedCategory = 'Все категории';
  String _sortCriteria = 'Дата создания';
  bool _showFavoritesOnly = false;
  TransactionType? _selectedType;
  DateTimeRange? _dateRange;

  // Геттеры
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get sortCriteria => _sortCriteria;
  bool get showFavoritesOnly => _showFavoritesOnly;
  TransactionType? get selectedType => _selectedType;
  DateTimeRange? get dateRange => _dateRange;

  // Отфильтрованные транзакции
  List<Transaction> get filteredTransactions {
    var list = _transactions.where((transaction) {
      // Фильтрация по поисковому запросу
      final query = _searchQuery.toLowerCase();
      final matchesQuery = query.isEmpty ||
          transaction.title.toLowerCase().contains(query) ||
          transaction.description.toLowerCase().contains(query) ||
          transaction.category.toLowerCase().contains(query);

      // Фильтрация по категории
      final matchesCategory = _selectedCategory == 'Все категории' ||
          transaction.category == _selectedCategory;

      // Фильтрация по типу транзакции
      final matchesType = _selectedType == null ||
          transaction.type == _selectedType;

      // Фильтрация по дате
      final matchesDate = _dateRange == null ||
          (transaction.createdAt.isAfter(_dateRange!.start) &&
              transaction.createdAt.isBefore(_dateRange!.end));

      // Фильтрация по избранному (если есть такое поле)
      // final matchesFavorite = !_showFavoritesOnly || transaction.isFavorite;
      final matchesFavorite = true; // Заглушка, если нет поля isFavorite

      return matchesQuery && matchesCategory && matchesType && matchesDate && matchesFavorite;
    }).toList();

    // Сортировка
    list.sort((a, b) {
      switch (_sortCriteria) {
        case 'Название':
          return a.title.compareTo(b.title);
        case 'Название (обратно)':
          return b.title.compareTo(a.title);
        case 'Дата создания':
          return b.createdAt.compareTo(a.createdAt);
        case 'Дата создания (старые)':
          return a.createdAt.compareTo(b.createdAt);
        case 'Сумма (возрастание)':
          return a.amount.compareTo(b.amount);
        case 'Сумма (убывание)':
          return b.amount.compareTo(a.amount);
        case 'Категория':
          return a.category.compareTo(b.category);
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return list;
  }

  // Методы для управления данными
  void setTransactions(List<Transaction> transactions) {
    _transactions = List.from(transactions);
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setSelectedCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void setSortCriteria(String value) {
    _sortCriteria = value;
    notifyListeners();
  }

  void toggleShowFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  void setSelectedType(TransactionType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'Все категории';
    _sortCriteria = 'Дата создания';
    _showFavoritesOnly = false;
    _selectedType = null;
    _dateRange = null;
    notifyListeners();
  }

  // Операции с транзакциями
  void deleteTransaction(String id) {
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
  }

  void deleteTransactions(List<String> ids) {
    _transactions.removeWhere((transaction) => ids.contains(transaction.id));
    notifyListeners();
  }

  void toggleTransactionType(String id) {
    final index = _transactions.indexWhere((transaction) => transaction.id == id);
    if (index != -1) {
      final transaction = _transactions[index];
      _transactions[index] = transaction.copyWith(
        type: transaction.isIncome ? TransactionType.expense : TransactionType.income,
      );
      notifyListeners();
    }
  }

  void updateTransaction(Transaction updatedTransaction) {
    final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
    }
  }

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction); // Добавляем в начало
    notifyListeners();
  }

  void addTransactions(List<Transaction> newTransactions) {
    _transactions.insertAll(0, newTransactions);
    notifyListeners();
  }

  // Получение статистики по отфильтрованным транзакциям
  double get filteredTotalIncome {
    return filteredTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get filteredTotalExpenses {
    return filteredTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get filteredBalance => filteredTotalIncome - filteredTotalExpenses;

  // Получение уникальных категорий из отфильтрованных транзакций
  Set<String> get availableCategories {
    final categories = _transactions.map((t) => t.category).toSet().toList();
    categories.sort();
    return categories.toSet();
  }

  // Статистика по отфильтрованным транзакциям
  Map<String, dynamic> get filteredStats {
    final filtered = filteredTransactions;

    if (filtered.isEmpty) {
      return {
        'count': 0,
        'totalIncome': 0.0,
        'totalExpenses': 0.0,
        'balance': 0.0,
        'averageAmount': 0.0,
      };
    }

    final income = filtered
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenses = filtered
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final averageAmount = filtered
        .fold(0.0, (sum, t) => sum + t.amount) / filtered.length;

    return {
      'count': filtered.length,
      'totalIncome': income,
      'totalExpenses': expenses,
      'balance': income - expenses,
      'averageAmount': averageAmount,
      'largestTransaction': filtered.reduce((a, b) =>
      a.amount > b.amount ? a : b),
      'smallestTransaction': filtered.reduce((a, b) =>
      a.amount < b.amount ? a : b),
    };
  }

  // Группировка транзакций по дате
  Map<String, List<Transaction>> get groupedByDate {
    final filtered = filteredTransactions;
    final grouped = <String, List<Transaction>>{};

    for (final transaction in filtered) {
      final dateKey = transaction.formattedDate;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  List<String> get groupedDates {
    return groupedByDate.keys.toList()..sort((a, b) => b.compareTo(a));
  }

  // Получить транзакции по категории
  List<Transaction> getTransactionsByCategory(String category) {
    return filteredTransactions
        .where((t) => t.category == category)
        .toList();
  }

  // Получить транзакции по типу
  List<Transaction> getTransactionsByType(TransactionType type) {
    return filteredTransactions
        .where((t) => t.type == type)
        .toList();
  }

  // Поиск транзакции по ID
  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Быстрая фильтрация
  void quickFilterToday() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));
    _dateRange = DateTimeRange(start: start, end: end);
    notifyListeners();
  }

  void quickFilterThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));
    _dateRange = DateTimeRange(start: start, end: end);
    notifyListeners();
  }

  void quickFilterThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    _dateRange = DateTimeRange(start: start, end: end);
    notifyListeners();
  }

  void quickFilterIncome() {
    _selectedType = TransactionType.income;
    notifyListeners();
  }

  void quickFilterExpenses() {
    _selectedType = TransactionType.expense;
    notifyListeners();
  }

  // Получить количество транзакций по категории
  int getCategoryCount(String category) {
    return filteredTransactions
        .where((t) => t.category == category)
        .length;
  }

  // Получить сумму по категории
  double getCategoryAmount(String category) {
    return filteredTransactions
        .where((t) => t.category == category)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Экспорт отфильтрованных транзакций
  List<Map<String, dynamic>> exportFilteredTransactions() {
    return filteredTransactions.map((t) => {
      'id': t.id,
      'title': t.title,
      'description': t.description,
      'amount': t.amount,
      'type': t.isIncome ? 'income' : 'expense',
      'category': t.category,
      'createdAt': t.createdAt.toIso8601String(),
      'formattedDate': t.formattedDate,
      'formattedAmount': t.formattedAmount,
    }).toList();
  }

  // Проверка, есть ли активные фильтры
  bool get hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _selectedCategory != 'Все категории' ||
        _selectedType != null ||
        _dateRange != null ||
        _showFavoritesOnly;
  }

  // Количество транзакций с текущими фильтрами
  int get filteredCount => filteredTransactions.length;

  // Процент от общего количества
  double get filteredPercentage {
    if (_transactions.isEmpty) return 0.0;
    return filteredCount / _transactions.length * 100;
  }

  // Очистка поискового запроса
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Сброс только типа
  void clearTypeFilter() {
    _selectedType = null;
    notifyListeners();
  }

  // Сброс только даты
  void clearDateFilter() {
    _dateRange = null;
    notifyListeners();
  }

  // Переключение сортировки
  void toggleSortOrder() {
    if (_sortCriteria == 'Дата создания') {
      _sortCriteria = 'Дата создания (старые)';
    } else if (_sortCriteria == 'Дата создания (старые)') {
      _sortCriteria = 'Дата создания';
    } else if (_sortCriteria == 'Сумма (возрастание)') {
      _sortCriteria = 'Сумма (убывание)';
    } else if (_sortCriteria == 'Сумма (убывание)') {
      _sortCriteria = 'Сумма (возрастание)';
    } else if (_sortCriteria == 'Название') {
      _sortCriteria = 'Название (обратно)';
    } else if (_sortCriteria == 'Название (обратно)') {
      _sortCriteria = 'Название';
    }
    notifyListeners();
  }

  // Получить текущее направление сортировки
  String get sortDirection {
    if (_sortCriteria.contains('(обратно)') ||
        _sortCriteria.contains('(убывание)') ||
        _sortCriteria.contains('(старые)')) {
      return 'desc';
    }
    return 'asc';
  }
}