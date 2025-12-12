import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:prac13/core/models/transaction_model.dart';

class TransactionInherited extends InheritedWidget {
  final ObservableList<Transaction> transactions; // Используем общий ObservableList

  const TransactionInherited({
    super.key,
    required this.transactions,
    required super.child,
  });

  static TransactionInherited of(BuildContext context) {
    final TransactionInherited? result =
    context.dependOnInheritedWidgetOfExactType<TransactionInherited>();
    assert(result != null, 'No TransactionInherited found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TransactionInherited oldWidget) {
    return oldWidget.transactions != transactions;
  }
}