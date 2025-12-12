import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:prac13/core/models/transaction_model.dart';
import 'package:prac13/core/constants/categories.dart';

class StatisticsStore with ChangeNotifier {
  List<Transaction> _transactions = [];
  String _searchQuery = '';
  String _selectedCategory = 'Все категории';
  DateTimeRange? _dateRange;

  // Геттеры
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  DateTimeRange? get dateRange => _dateRange;

  // Основные статистические показатели
  double get totalIncome {
    final filtered = _filterTransactionsByFilters();
    return filtered
        .where((transaction) => transaction.isIncome)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalExpenses {
    final filtered = _filterTransactionsByFilters();
    return filtered
        .where((transaction) => transaction.isExpense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get balance => totalIncome - totalExpenses;

  double get averageDailyExpense {
    if (_dateRange == null) return 0.0;
    final days = _dateRange!.duration.inDays + 1;
    return days > 0 ? totalExpenses / days : 0.0;
  }

  double get averageDailyIncome {
    if (_dateRange == null) return 0.0;
    final days = _dateRange!.duration.inDays + 1;
    return days > 0 ? totalIncome / days : 0.0;
  }

  // Статистика по категориям
  Map<String, double> get incomeStats {
    final filtered = _filterTransactionsByFilters()
        .where((t) => t.type == TransactionType.income)
        .toList();
    final grouped = groupBy(filtered, (t) => t.category);
    return grouped.map((category, transactions) => MapEntry(
      category,
      transactions.fold(0.0, (sum, t) => sum + t.amount),
    ));
  }

  Map<String, double> get expenseStats {
    final filtered = _filterTransactionsByFilters()
        .where((t) => t.type == TransactionType.expense)
        .toList();
    final grouped = groupBy(filtered, (t) => t.category);
    return grouped.map((category, transactions) => MapEntry(
      category,
      transactions.fold(0.0, (sum, t) => sum + t.amount),
    ));
  }

  // Топ категорий расходов
  List<MapEntry<String, double>> get topExpenseCategories {
    final stats = expenseStats;
    final entries = stats.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  // Топ категорий доходов
  List<MapEntry<String, double>> get topIncomeCategories {
    final stats = incomeStats;
    final entries = stats.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
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

  void setDateRange(DateTimeRange range) {
    _dateRange = range;
    notifyListeners();
  }

  void clearDateRange() {
    _dateRange = null;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'Все категории';
    _dateRange = null;
    notifyListeners();
  }

  // Вспомогательные методы

  List<Transaction> _filterTransactionsByFilters() {
    var filtered = _transactions;

    // Фильтрация по категории
    if (_selectedCategory != 'Все категории') {
      filtered = filtered.where((t) => t.category == _selectedCategory).toList();
    }

    // Фильтрация по дате
    if (_dateRange != null) {
      filtered = filtered.where((t) =>
      t.createdAt.isAfter(_dateRange!.start) &&
          t.createdAt.isBefore(_dateRange!.end)).toList();
    }

    // Фильтрация по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) =>
      t.title.toLowerCase().contains(query) ||
          t.description.toLowerCase().contains(query) ||
          t.category.toLowerCase().contains(query)).toList();
    }

    return filtered;
  }

  List<Transaction> get filteredTransactions => _filterTransactionsByFilters();

  // Статистика по месяцам
  Map<String, double> get monthlyExpenses {
    final expenses = _transactions.where((t) => t.isExpense).toList();
    final grouped = groupBy(expenses, (t) =>
    '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}');

    return grouped.map((month, transactions) => MapEntry(
      month,
      transactions.fold(0.0, (sum, t) => sum + t.amount),
    ));
  }

  Map<String, double> get monthlyIncome {
    final income = _transactions.where((t) => t.isIncome).toList();
    final grouped = groupBy(income, (t) =>
    '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}');

    return grouped.map((month, transactions) => MapEntry(
      month,
      transactions.fold(0.0, (sum, t) => sum + t.amount),
    ));
  }

  // Статистика по дням недели
  Map<String, double> get expensesByWeekday {
    final expenses = _transactions.where((t) => t.isExpense).toList();
    final weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    final Map<String, double> result = {};
    for (int i = 0; i < 7; i++) {
      result[weekdays[i]] = 0.0;
    }

    for (final expense in expenses) {
      final weekday = expense.createdAt.weekday - 1; // 0 = Monday
      result[weekdays[weekday]] = (result[weekdays[weekday]] ?? 0) + expense.amount;
    }

    return result;
  }

  // Самые крупные транзакции
  List<Transaction> get topExpenses {
    final expenses = _transactions.where((t) => t.isExpense).toList();
    expenses.sort((a, b) => b.amount.compareTo(a.amount));
    return expenses.take(10).toList();
  }

  List<Transaction> get topIncomes {
    final incomes = _transactions.where((t) => t.isIncome).toList();
    incomes.sort((a, b) => b.amount.compareTo(a.amount));
    return incomes.take(10).toList();
  }

  // Статистика за последние N дней
  Map<String, double> getLastNDaysExpenses(int days) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    final expenses = _transactions.where((t) =>
    t.isExpense &&
        t.createdAt.isAfter(startDate) &&
        t.createdAt.isBefore(endDate.add(Duration(days: 1)))).toList();

    final result = <String, double>{};
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final key = '${date.day}.${date.month}';
      result[key] = 0.0;
    }

    for (final expense in expenses) {
      final key = '${expense.createdAt.day}.${expense.createdAt.month}';
      result[key] = (result[key] ?? 0) + expense.amount;
    }

    return result;
  }

  Map<String, double> getLastNDaysIncome(int days) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    final incomes = _transactions.where((t) =>
    t.isIncome &&
        t.createdAt.isAfter(startDate) &&
        t.createdAt.isBefore(endDate.add(Duration(days: 1)))).toList();

    final result = <String, double>{};
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final key = '${date.day}.${date.month}';
      result[key] = 0.0;
    }

    for (final income in incomes) {
      final key = '${income.createdAt.day}.${income.createdAt.month}';
      result[key] = (result[key] ?? 0) + income.amount;
    }

    return result;
  }

  // Процентное соотношение расходов по категориям
  Map<String, double> get expensePercentages {
    final stats = expenseStats;
    final total = totalExpenses;

    if (total == 0) return {};

    return stats.map((category, amount) =>
        MapEntry(category, (amount / total * 100)));
  }

  Map<String, double> get incomePercentages {
    final stats = incomeStats;
    final total = totalIncome;

    if (total == 0) return {};

    return stats.map((category, amount) =>
        MapEntry(category, (amount / total * 100)));
  }

  // Прогноз на следующий месяц
  double get projectedNextMonthExpenses {
    if (_transactions.isEmpty) return 0.0;

    final now = DateTime.now();
    final firstDayOfThisMonth = DateTime(now.year, now.month, 1);
    final daysPassed = now.difference(firstDayOfThisMonth).inDays + 1;

    if (daysPassed < 7) return 0.0; // Недостаточно данных

    final thisMonthExpenses = _transactions
        .where((t) => t.isExpense && t.createdAt.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);

    final dailyAverage = thisMonthExpenses / daysPassed;
    return dailyAverage * 30;
  }

  double get projectedNextMonthIncome {
    if (_transactions.isEmpty) return 0.0;

    final now = DateTime.now();
    final firstDayOfThisMonth = DateTime(now.year, now.month, 1);
    final daysPassed = now.difference(firstDayOfThisMonth).inDays + 1;

    if (daysPassed < 7) return 0.0; // Недостаточно данных

    final thisMonthIncome = _transactions
        .where((t) => t.isIncome && t.createdAt.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);

    final dailyAverage = thisMonthIncome / daysPassed;
    return dailyAverage * 30;
  }

  // Получить все уникальные категории
  Set<String> get allCategories {
    return _transactions.map((t) => t.category).toSet();
  }

  Set<String> get expenseCategories {
    return _transactions
        .where((t) => t.isExpense)
        .map((t) => t.category)
        .toSet();
  }

  Set<String> get incomeCategories {
    return _transactions
        .where((t) => t.isIncome)
        .map((t) => t.category)
        .toSet();
  }

  // Экспорт статистики в Map
  Map<String, dynamic> toMap() {
    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': balance,
      'averageDailyExpense': averageDailyExpense,
      'averageDailyIncome': averageDailyIncome,
      'incomeStats': incomeStats,
      'expenseStats': expenseStats,
      'topExpenseCategories': topExpenseCategories.map((e) =>
      {'category': e.key, 'amount': e.value}).toList(),
      'topIncomeCategories': topIncomeCategories.map((e) =>
      {'category': e.key, 'amount': e.value}).toList(),
    };
  }
}