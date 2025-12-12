import 'package:flutter/foundation.dart';

class CalculatorStore with ChangeNotifier {
  String _currentInput = '0';
  String _expression = '';
  List<String> _history = [];
  bool _shouldResetInput = false;

  String get currentInput => _currentInput;
  String get expression => _expression;
  List<String> get history => List.unmodifiable(_history);
  bool get shouldResetInput => _shouldResetInput;

  void appendNumber(String number) {
    if (_shouldResetInput) {
      _currentInput = number;
      _shouldResetInput = false;
    } else {
      if (_currentInput == '0') {
        _currentInput = number;
      } else {
        _currentInput += number;
      }
    }
    notifyListeners();
  }

  void appendDecimal() {
    if (_shouldResetInput) {
      _currentInput = '0.';
      _shouldResetInput = false;
    } else if (!_currentInput.contains('.')) {
      _currentInput += '.';
    }
    notifyListeners();
  }

  void setOperation(String operation) {
    if (_shouldResetInput) {
      _expression = '$_currentInput $operation ';
      _shouldResetInput = false;
    } else {
      _expression = '$_expression$_currentInput $operation ';
      _currentInput = '0';
    }
    notifyListeners();
  }

  void calculate() {
    if (_expression.isEmpty) return;

    final fullExpression = '$_expression$_currentInput';
    final parts = fullExpression.split(' ');

    if (parts.length != 3) return;

    final num1 = double.tryParse(parts[0]);
    final operator = parts[1];
    final num2 = double.tryParse(parts[2]);

    if (num1 == null || num2 == null) return;

    double result;
    switch (operator) {
      case '+':
        result = num1 + num2;
        break;
      case '-':
        result = num1 - num2;
        break;
      case '×':
        result = num1 * num2;
        break;
      case '÷':
        result = num1 / num2;
        break;
      default:
        return;
    }

    // Добавляем в историю
    final historyEntry = '$fullExpression = ${result.toStringAsFixed(2)}';
    _history.insert(0, historyEntry);
    if (_history.length > 10) {
      _history.removeLast();
    }

    // Обновляем состояние
    _currentInput = result.toStringAsFixed(2).replaceAll(RegExp(r'\.0$'), '');
    _expression = '';
    _shouldResetInput = true;

    notifyListeners();
  }

  void clear() {
    _currentInput = '0';
    _expression = '';
    notifyListeners();
  }

  void clearAll() {
    _currentInput = '0';
    _expression = '';
    _history.clear();
    notifyListeners();
  }

  void toggleSign() {
    if (_currentInput != '0') {
      if (_currentInput.startsWith('-')) {
        _currentInput = _currentInput.substring(1);
      } else {
        _currentInput = '-$_currentInput';
      }
      notifyListeners();
    }
  }

  void percentage() {
    final value = double.tryParse(_currentInput);
    if (value != null) {
      _currentInput = (value / 100).toString();
      _shouldResetInput = true;
      notifyListeners();
    }
  }

  void deleteLast() {
    if (_currentInput.length > 1) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    } else {
      _currentInput = '0';
    }
    notifyListeners();
  }
}