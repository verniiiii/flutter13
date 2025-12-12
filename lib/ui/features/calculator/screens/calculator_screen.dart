import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/ui/features/calculator/state/calculator_store.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = GetIt.I<CalculatorStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistoryDialog(context, store),
            tooltip: 'История вычислений',
          ),
        ],
      ),
      body: Column(
        children: [
          // Дисплей
          _buildDisplay(context, store),

          // Клавиатура
          Expanded(
            child: _buildKeyboard(context, store),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplay(BuildContext context, CalculatorStore store) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Выражение
          Observer(
            builder: (_) => Text(
              store.expression,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Текущий ввод
          Observer(
            builder: (_) => Text(
              store.currentInput,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboard(BuildContext context, CalculatorStore store) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Первый ряд - специальные кнопки
          Expanded(
            child: Row(
              children: [
                _buildCalculatorButton(
                  context: context,
                  text: 'C',
                  onPressed: store.clear,
                  backgroundColor: Colors.grey[300],
                  textColor: Colors.black,
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '⌫',
                  onPressed: store.deleteLast,
                  backgroundColor: Colors.grey[300],
                  textColor: Colors.black,
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '%',
                  onPressed: store.percentage,
                  backgroundColor: Colors.grey[300],
                  textColor: Colors.black,
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '÷',
                  onPressed: () => store.setOperation('÷'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),

          // Второй ряд
          Expanded(
            child: Row(
              children: [
                _buildCalculatorButton(
                  context: context,
                  text: '7',
                  onPressed: () => store.appendNumber('7'),
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '8',
                  onPressed: () => store.appendNumber('8'),
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '9',
                  onPressed: () => store.appendNumber('9'),
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '×',
                  onPressed: () => store.setOperation('×'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),

          // Третий ряд
          Expanded(
            child: Row(
              children: [
                _buildCalculatorButton(
                  context: context,
                  text: '4',
                  onPressed: () => store.appendNumber('4'),
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '5',
                  onPressed: () => store.appendNumber('5'),
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '6',
                  onPressed: () => store.appendNumber('6'),
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '-',
                  onPressed: () => store.setOperation('-'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),

          // Четвертый ряд
          Expanded(
            child: Row(
              children: [
                _buildCalculatorButton(
                  context: context,
                  text: '1',
                  onPressed: () => store.appendNumber('1'),
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '2',
                  onPressed: () => store.appendNumber('2'),
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '3',
                  onPressed: () => store.appendNumber('3'),
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '+',
                  onPressed: () => store.setOperation('+'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),

          // Пятый ряд
          Expanded(
            child: Row(
              children: [
                _buildCalculatorButton(
                  context: context,
                  text: '+/-',
                  onPressed: store.toggleSign,
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '0',
                  onPressed: () => store.appendNumber('0'),
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '.',
                  onPressed: store.appendDecimal,
                ),
                _buildCalculatorButton(
                  context: context,
                  text: '=',
                  onPressed: store.calculate,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Material(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: textColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context, CalculatorStore store) {
    showDialog(
      context: context,
      builder: (context) => Observer(
        builder: (_) => AlertDialog(
          title: const Text('История вычислений'),
          content: store.history.isEmpty
              ? const Text('История вычислений пуста')
              : SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: store.history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(store.history[index]),
                  onTap: () {
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            if (store.history.isNotEmpty)
              TextButton(
                onPressed: store.clearAll,
                child: const Text('Очистить историю'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      ),
    );
  }
}