import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/ui/features/transactions/state/transaction_details_store.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailsScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<TransactionDetailsStore>();

    return Observer(
      builder: (_) {
        // Получаем транзакцию из store по ID используя computed свойство
        final transaction = store.getTransactionById(transactionId);

        // Если транзакция не найдена, показываем заглушку
        if (transaction == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Детали транзакции'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
            ),
            body: const Center(
              child: Text('Транзакция не найдена'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Детали транзакции'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go('/');
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Observer(
                          builder: (_) => Text(
                            transaction.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Observer(
                          builder: (_) => Text(
                            transaction.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Сумма:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Observer(
                              builder: (_) => Text(
                                '${transaction.amount.toStringAsFixed(2)} ₽',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: transaction.isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Категория:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Observer(
                              builder: (_) => Text(
                                transaction.category,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Тип:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Observer(
                              builder: (_) => Text(
                                transaction.type.displayName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Дата:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Observer(
                              builder: (_) => Text(
                                '${transaction.createdAt.day}.${transaction.createdAt.month}.${transaction.createdAt.year}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text('Назад (Pop)'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

