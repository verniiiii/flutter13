import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:prac13/core/models/transaction_model.dart';
import 'transaction_row.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;
  final ValueChanged<Transaction> onEdit;
  final ValueChanged<String> onDetails;
  final double totalIncome;
  final double totalExpenses;
  final double balance;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onDetails,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Column(
        children: [
          // Сводка финансов
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Общий баланс',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Observer(
                    builder: (_) => Text(
                      '${balance.toStringAsFixed(2)} ₽',
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: balance >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Доходы',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Observer(
                            builder: (_) => Text(
                              '${totalIncome.toStringAsFixed(2)} ₽',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Расходы',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Observer(
                            builder: (_) => Text(
                              '${totalExpenses.toStringAsFixed(2)} ₽',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Заголовок списка
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Последние транзакции',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Observer(
                  builder: (_) => Text(
                    '${transactions.length} шт',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Список транзакций
          Expanded(
            child: Observer(
              builder: (_) => transactions.isEmpty
                  ? const Center(
                child: Text('Нет транзакций'),
              )
                  : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return TransactionRow(
                    transaction: transaction,
                    onToggle: onToggle,
                    onDelete: onDelete,
                    onEdit: onEdit,
                    onDetails: onDetails,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

