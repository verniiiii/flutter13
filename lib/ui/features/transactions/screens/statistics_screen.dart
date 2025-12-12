import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/core/constants/categories.dart';
import 'package:prac13/ui/features/transactions/state/statistics_store.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<StatisticsStore>(); // Меняем на StatisticsStore

    return Observer( // Оборачиваем в Observer для реактивных обновлений
      builder: (_) {
        // Используем computed свойства из StatisticsStore
        final incomeStats = store.incomeStats;
        final expenseStats = store.expenseStats;
        final totalIncome = store.totalIncome;
        final totalExpenses = store.totalExpenses;
        final balance = store.balance;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Статистика'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Поиск и фильтрация
                Observer(
                  builder: (_) => Column(
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
                      DropdownButtonFormField<String>(
                        value: store.selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Категория',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'Все категории',
                          ...TransactionCategories.incomeCategories,
                          ...TransactionCategories.expenseCategories,
                        ].map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          store.setSelectedCategory(newValue!);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Сводка
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Общая статистика',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Доходы', '${totalIncome.toStringAsFixed(2)} ₽', Colors.green),
                            _buildStatItem('Расходы', '${totalExpenses.toStringAsFixed(2)} ₽', Colors.red),
                            _buildStatItem('Баланс', '${balance.toStringAsFixed(2)} ₽',
                                balance >= 0 ? Colors.green : Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Статистика по доходам
                _buildCategorySection('Доходы по категориям', incomeStats, totalIncome, Colors.green),
                const SizedBox(height: 20),

                // Статистика по расходам
                _buildCategorySection('Расходы по категориям', expenseStats, totalExpenses, Colors.red),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(String title, Map<String, double> stats, double total, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            if (stats.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Нет данных для отображения'),
              )
            else
              ...stats.entries.map((entry) => _buildCategoryRow(
                entry.key,
                entry.value,
                total,
                color,
              )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String category, double amount, double total, Color color) {
    final percentage = total > 0 ? (amount / total * 100) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(category),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${amount.toStringAsFixed(2)} ₽\n${percentage.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

