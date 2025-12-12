import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:prac13/core/models/transaction_model.dart';

class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;
  final ValueChanged<Transaction> onEdit;
  final ValueChanged<String> onDetails;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final transactions = GetIt.I<ObservableList<Transaction>>();

    return Observer(
      builder: (_) {
        final currentTransaction = transactions.firstWhere(
              (t) => t.id == transaction.id,
          orElse: () => transaction,
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: Observer(
              builder: (_) => Icon(
                currentTransaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: currentTransaction.isIncome ? Colors.green : Colors.red,
              ),
            ),
            title: Observer(
              builder: (_) => Text(currentTransaction.title),
            ),
            subtitle: Observer(
              builder: (_) => Text(
                '${currentTransaction.category} • '
                    '${currentTransaction.createdAt.day}.${currentTransaction.createdAt.month}.${currentTransaction.createdAt.year}',
              ),
            ),
            trailing: Observer(
              builder: (_) => Text(
                '${currentTransaction.isIncome ? '+' : '-'}${currentTransaction.amount.toStringAsFixed(2)} ₽',
                style: TextStyle(
                  color: currentTransaction.isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () => _showOptions(context, currentTransaction),
          ),
        );
      },
    );
  }

  void _showOptions(BuildContext context, Transaction transaction) {
    final transactions = GetIt.I<ObservableList<Transaction>>();

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Редактировать'),
            onTap: () {
              Navigator.pop(context);
              onDetails(transaction.id);
            },
          ),
          Observer(
            builder: (_) {
              final currentTransaction = transactions.firstWhere(
                    (t) => t.id == transaction.id,
                orElse: () => transaction,
              );

              return ListTile(
                leading: Icon(
                  currentTransaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: currentTransaction.isIncome ? Colors.red : Colors.green,
                ),
                title: Text(
                  currentTransaction.isIncome ? 'Сделать расходом' : 'Сделать доходом',
                ),
                onTap: () {
                  Navigator.pop(context);
                  onToggle(transaction.id);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Удалить', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onDelete(transaction.id);
            },
          ),
        ],
      ),
    );
  }
}

