import 'package:flutter/foundation.dart';
import 'package:prac13/core/models/transaction_model.dart';

import '../../../../core/constants/categories.dart';

class TransactionDetailsStore with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  void setTransactions(List<Transaction> transactions) {
    _transactions = List.from(transactions);
    notifyListeners();
  }

  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  // Дополнительные методы для работы с транзакцией

  void deleteTransaction(String id) {
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
  }

  void updateTransaction(Transaction updatedTransaction) {
    final index = _transactions.indexWhere((transaction) =>
    transaction.id == updatedTransaction.id);

    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
    }
  }

  void toggleFavorite(String id) {
    final transaction = getTransactionById(id);
    if (transaction != null) {
      // Здесь можно добавить логику пометки транзакции как избранной
      // если в модели Transaction есть поле isFavorite
      notifyListeners();
    }
  }

  List<Transaction> getSimilarTransactions(String currentTransactionId) {
    final currentTransaction = getTransactionById(currentTransactionId);
    if (currentTransaction == null) return [];

    // Находим транзакции с той же категорией, исключая текущую
    return _transactions.where((transaction) =>
    transaction.id != currentTransactionId &&
        transaction.category == currentTransaction.category).toList();
  }

  List<Transaction> getTransactionsFromSameDate(String transactionId) {
    final transaction = getTransactionById(transactionId);
    if (transaction == null) return [];

    final transactionDate = DateTime(
      transaction.createdAt.year,
      transaction.createdAt.month,
      transaction.createdAt.day,
    );

    return _transactions.where((t) {
      final tDate = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      return t.id != transactionId && tDate == transactionDate;
    }).toList();
  }

  Transaction? getNextTransaction(String currentTransactionId) {
    final sortedTransactions = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final currentIndex = sortedTransactions.indexWhere((t) =>
    t.id == currentTransactionId);

    if (currentIndex != -1 && currentIndex > 0) {
      return sortedTransactions[currentIndex - 1];
    }

    return null;
  }

  Transaction? getPreviousTransaction(String currentTransactionId) {
    final sortedTransactions = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final currentIndex = sortedTransactions.indexWhere((t) =>
    t.id == currentTransactionId);

    if (currentIndex != -1 && currentIndex < sortedTransactions.length - 1) {
      return sortedTransactions[currentIndex + 1];
    }

    return null;
  }

  double getCategoryTotalForMonth(String transactionId) {
    final transaction = getTransactionById(transactionId);
    if (transaction == null) return 0.0;

    final now = DateTime.now();
    return _transactions
        .where((t) =>
    t.category == transaction.category &&
        t.createdAt.month == now.month &&
        t.createdAt.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getCategoryAverage(String transactionId) {
    final transaction = getTransactionById(transactionId);
    if (transaction == null) return 0.0;

    final categoryTransactions = _transactions
        .where((t) => t.category == transaction.category)
        .toList();

    if (categoryTransactions.isEmpty) return 0.0;

    final total = categoryTransactions.fold(0.0, (sum, t) => sum + t.amount);
    return total / categoryTransactions.length;
  }

  int getTransactionCountInCategory(String transactionId) {
    final transaction = getTransactionById(transactionId);
    if (transaction == null) return 0;

    return _transactions
        .where((t) => t.category == transaction.category)
        .length;
  }

  // Статистика по месяцу для текущей транзакции
  Map<String, dynamic> getMonthlyStatsForTransaction(String transactionId) {
    final transaction = getTransactionById(transactionId);
    if (transaction == null) return {};

    final now = DateTime.now();
    final currentMonthTransactions = _transactions
        .where((t) =>
    t.createdAt.month == now.month &&
        t.createdAt.year == now.year)
        .toList();

    final totalIncome = currentMonthTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpenses = currentMonthTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final categoryExpenses = currentMonthTransactions
        .where((t) => t.category == transaction.category && t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
      'categoryTotal': categoryExpenses,
      'categoryPercentage': totalExpenses > 0
          ? (categoryExpenses / totalExpenses * 100)
          : 0,
    };
  }

  // Поиск похожих транзакций по описанию
  List<Transaction> findSimilarByDescription(String transactionId) {
    final transaction = getTransactionById(transactionId);
    if (transaction == null || transaction.description.isEmpty) return [];

    final keywords = transaction.description
        .toLowerCase()
        .split(' ')
        .where((word) => word.length > 3)
        .toList();

    if (keywords.isEmpty) return [];

    return _transactions.where((t) {
      if (t.id == transactionId) return false;

      final description = t.description.toLowerCase();
      return keywords.any((keyword) => description.contains(keyword));
    }).toList();
  }

  // Получить все транзакции за определенный период
  List<Transaction> getTransactionsInDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) =>
    t.createdAt.isAfter(start) && t.createdAt.isBefore(end)).toList();
  }

  // Добавить транзакцию
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  // Добавить несколько транзакций
  void addTransactions(List<Transaction> newTransactions) {
    _transactions.addAll(newTransactions);
    notifyListeners();
  }

  // Очистить все транзакции
  void clearTransactions() {
    _transactions.clear();
    notifyListeners();
  }

  // Получить транзакции по категории
  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions
        .where((t) => t.category == category)
        .toList();
  }

  // Получить транзакции по типу
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions
        .where((t) => t.type == type)
        .toList();
  }

  // Получить транзакции по сумме (диапазон)
  List<Transaction> getTransactionsByAmountRange(double min, double max) {
    return _transactions
        .where((t) => t.amount >= min && t.amount <= max)
        .toList();
  }

  // Поиск транзакций по тексту
  List<Transaction> searchTransactions(String query) {
    if (query.isEmpty) return [];

    final searchTerm = query.toLowerCase();
    return _transactions.where((t) =>
    t.title.toLowerCase().contains(searchTerm) ||
        t.description.toLowerCase().contains(searchTerm) ||
        t.category.toLowerCase().contains(searchTerm)).toList();
  }

  // Получить статистику по транзакциям
  Map<String, dynamic> getTransactionStats() {
    if (_transactions.isEmpty) {
      return {
        'count': 0,
        'totalIncome': 0.0,
        'totalExpenses': 0.0,
        'averageAmount': 0.0,
        'largestTransaction': null,
      };
    }

    final income = _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expenses = _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final largestTransaction = _transactions.reduce((a, b) =>
    a.amount > b.amount ? a : b);

    final averageAmount = _transactions
        .fold(0.0, (sum, t) => sum + t.amount) / _transactions.length;

    return {
      'count': _transactions.length,
      'totalIncome': income,
      'totalExpenses': expenses,
      'balance': income - expenses,
      'averageAmount': averageAmount,
      'largestTransaction': largestTransaction,
    };
  }

  // Получить транзакции за сегодня
  List<Transaction> getTodayTransactions() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return getTransactionsInDateRange(todayStart, todayEnd);
  }

  // Получить транзакции за неделю
  List<Transaction> getThisWeekTransactions() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));

    return getTransactionsInDateRange(start, end);
  }

  // Получить транзакции за месяц
  List<Transaction> getThisMonthTransactions() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    return getTransactionsInDateRange(start, end);
  }

  // Экспорт данных в удобном формате
  Map<String, dynamic> exportData() {
    return {
      'transactions': _transactions.map((t) => {
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'amount': t.amount,
        'type': t.type == TransactionType.income ? 'income' : 'expense',
        'category': t.category,
        'createdAt': t.createdAt.toIso8601String(),
        'formattedDate': t.formattedDate,
        'formattedAmount': t.formattedAmount,
      }).toList(),
      'stats': getTransactionStats(),
    };
  }
}