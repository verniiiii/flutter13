import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/core/models/transaction_model.dart';
import 'package:prac13/core/constants/categories.dart';
import 'package:prac13/ui/features/transactions/state/edit_transaction_store.dart';

class EditTransactionScreen extends StatelessWidget {
  final Transaction transaction;
  final void Function(Transaction) onUpdate;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
    required this.onUpdate,
  });

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<EditTransactionStore>();

    // Инициализируем store при первом построении
    if (store.title.isEmpty) {
      store.setTitle(transaction.title);
      store.setDescription(transaction.description);
      store.setAmount(transaction.amount);
      store.setType(transaction.type);
      store.setSelectedCategory(transaction.category);
    }

    return Observer(
      builder: (_) {
        final categories = TransactionCategories.getCategoriesForType(
            store.type);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Редактировать транзакцию'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment<TransactionType>(
                      value: TransactionType.expense,
                      label: Text('Расход'),
                      icon: Icon(Icons.arrow_upward),
                    ),
                    ButtonSegment<TransactionType>(
                      value: TransactionType.income,
                      label: Text('Доход'),
                      icon: Icon(Icons.arrow_downward),
                    ),
                  ],
                  selected: {store.type},
                  onSelectionChanged: (Set<TransactionType> newSelection) {
                    final newType = newSelection.first;
                    store.setType(newType);
                    store.setSelectedCategory(
                        TransactionCategories.getDefaultCategoryForType(newType)
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: TextEditingController(text: store.title),
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => store.setTitle(value),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: store.description),
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) => store.setDescription(value),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(
                      text: store.amount > 0
                          ? store.amount.toStringAsFixed(2)
                          : ''
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    border: OutlineInputBorder(),
                    prefixText: '₽',
                  ),
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0.0;
                    store.setAmount(amount);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: store.selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    store.setSelectedCategory(newValue!);
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (store.title.isEmpty || store.amount <= 0) {
                      _showError(
                          context, 'Заполните название и сумму (больше 0)');
                      return;
                    }

                    store.updateTransaction(transaction.id);

                    final updatedTransaction = transaction.copyWith(
                      title: store.title,
                      description: store.description,
                      amount: store.amount,
                      type: store.type,
                      category: store.selectedCategory,
                    );

                    onUpdate(updatedTransaction);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Сохранить изменения'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

