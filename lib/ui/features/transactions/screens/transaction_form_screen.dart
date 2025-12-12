import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:prac13/core/models/transaction_model.dart';
import 'package:prac13/core/constants/categories.dart';
import 'package:prac13/ui/features/transactions/state/transaction_form_store.dart';

class TransactionFormScreen extends StatelessWidget {
  final void Function(Transaction) onSave;

  const TransactionFormScreen({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<TransactionFormStore>();

    return Observer(
      builder: (_) {
        final categories = TransactionCategories.getCategoriesForType(store.type);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Добавить транзакцию'),
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
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => store.setTitle(value),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) => store.setDescription(value),
                ),
                const SizedBox(height: 10),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    border: OutlineInputBorder(),
                    prefixText: '₽',
                  ),
                  onChanged: (value) {
                    final amount = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                    store.setAmount(amount);
                  },
                ),
                const SizedBox(height: 10),
                Observer(
                  builder: (_) => DropdownButtonFormField<String>(
                    value: store.selectedCategory.isEmpty
                        ? TransactionCategories.getDefaultCategoryForType(store.type)
                        : store.selectedCategory,
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
                ),
                const SizedBox(height: 30),
                Observer(
                  builder: (_) => ElevatedButton(
                    onPressed: store.title.isNotEmpty && store.amount > 0
                        ? () {
                      store.addTransaction();

                      final newTransaction = Transaction(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        title: store.title,
                        description: store.description,
                        amount: store.amount,
                        createdAt: DateTime.now(),
                        type: store.type,
                        category: store.selectedCategory,
                      );

                      onSave(newTransaction);
                      Navigator.pop(context);
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Добавить транзакцию'),
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

