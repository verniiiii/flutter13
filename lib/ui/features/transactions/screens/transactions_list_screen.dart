import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/ui/features/transactions/widgets/transaction_list.dart';
import 'package:prac13/core/models/transaction_model.dart';
import 'package:prac13/core/constants/categories.dart';
import 'package:prac13/ui/features/transactions/state/transactions_list_store.dart';

class TransactionsListScreen extends StatelessWidget {
  const TransactionsListScreen({super.key});

  void _addTransaction(BuildContext context) {
    context.push('/add');
  }

  void _toggleTransaction(TransactionsListStore store, String id) {
    store.toggleTransactionType(id);
  }

  void _deleteTransaction(TransactionsListStore store, String id) {
    store.deleteTransaction(id);
  }

  void _editTransaction(BuildContext context, Transaction transaction) {
    context.push('/edit/${transaction.id}', extra: transaction);
  }

  void _showTransactionDetails(BuildContext context, String transactionId) {
    context.pushReplacement('/details?id=$transactionId');
  }

  void _showStatistics(BuildContext context) {
    context.push('/statistics');
  }

  void _showProfile(BuildContext context) {
    context.push('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<TransactionsListStore>();
    final allCategories = ['Все категории', ...TransactionCategories.incomeCategories, ...TransactionCategories.expenseCategories];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Финансовый Трекер'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showStatistics(context),
            tooltip: 'Статистика',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfile(context),
            tooltip: 'Профиль',
          ),
          IconButton(
            icon: const Icon(Icons.credit_card),
            onPressed: () => context.push('/cards'),
            tooltip: 'Мои карты',
          ),
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () => context.push('/calculator'),
            tooltip: 'Калькулятор',
          ),
          IconButton(
            icon: const Icon(Icons.emoji_objects),
            onPressed: () => context.push('/motivation'),
            tooltip: 'Мотивация',
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.push('/friends'),
            tooltip: 'Друзья в приложении',
          ),
          IconButton(
            icon: const Icon(Icons.newspaper),
            onPressed: () => context.push('/news'),
            tooltip: 'Новости и курсы',
          ),
        ],
      ),
      body: Observer(
        builder: (_) => Column(
          children: [
            // Поиск и фильтрация
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Поиск транзакций',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => store.setSearchQuery(value),
                  ),
                  const SizedBox(height: 10),
                  Observer(
                    builder: (_) => DropdownButtonFormField<String>(
                      value: store.selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Категория',
                        border: OutlineInputBorder(),
                      ),
                      items: allCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        store.setSelectedCategory(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Observer(
                    builder: (_) => DropdownButtonFormField<String>(
                      value: store.sortCriteria,
                      decoration: const InputDecoration(
                        labelText: 'Сортировка',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Дата создания',
                          child: Text('По дате (сначала новые)'),
                        ),
                        DropdownMenuItem(
                          value: 'Название',
                          child: Text('По названию (А-Я)'),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        store.setSortCriteria(newValue!);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) => TransactionList(
                  transactions: store.filteredTransactions,
                  onToggle: (id) => _toggleTransaction(store, id),
                  onDelete: (id) => _deleteTransaction(store, id),
                  onEdit: (transaction) => _editTransaction(context, transaction),
                  onDetails: (transactionId) => _showTransactionDetails(context, transactionId),
                  totalIncome: store.transactions
                      .where((t) => t.isIncome)
                      .fold(0.0, (sum, t) => sum + t.amount),
                  totalExpenses: store.transactions
                      .where((t) => t.isExpense)
                      .fold(0.0, (sum, t) => sum + t.amount),
                  balance: store.transactions
                      .where((t) => t.isIncome)
                      .fold(0.0, (sum, t) => sum + t.amount) -
                      store.transactions
                          .where((t) => t.isExpense)
                          .fold(0.0, (sum, t) => sum + t.amount),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

