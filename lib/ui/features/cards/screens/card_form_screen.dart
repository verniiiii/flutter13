import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:prac13/ui/features/cards/state/cards_store.dart';
import 'package:prac13/core/models/card_model.dart';

class CardFormScreen extends StatefulWidget {
  final CardModel? card;

  const CardFormScreen({super.key, this.card});

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final CardsStore store = GetIt.I<CardsStore>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _cardNumberController;
  late TextEditingController _cardHolderController;
  late TextEditingController _bankNameController;
  late TextEditingController _balanceController;
  late TextEditingController _creditLimitController;
  late TextEditingController _cvvController;

  late CardType _selectedType;
  late CardColor _selectedColor;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365 * 3));

  @override
  void initState() {
    super.initState();

    final card = widget.card;
    _cardNumberController = TextEditingController(text: card?.cardNumber ?? '');
    _cardHolderController = TextEditingController(text: card?.cardHolderName ?? '');
    _bankNameController = TextEditingController(text: card?.bankName ?? '');
    _balanceController = TextEditingController(text: card?.balance.toStringAsFixed(2) ?? '0.00');
    _creditLimitController = TextEditingController(text: card?.creditLimit?.toStringAsFixed(2) ?? '');
    _cvvController = TextEditingController(text: card?.cvv ?? '');

    _selectedType = card?.cardType ?? CardType.debit;
    _selectedColor = card?.cardColor ?? CardColor.blue;
    _expiryDate = card?.expiryDate ?? DateTime.now().add(const Duration(days: 365 * 3));
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _bankNameController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final card = CardModel(
        id: widget.card?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardHolderName: _cardHolderController.text.toUpperCase(),
        expiryDate: _expiryDate,
        cvv: _cvvController.text,
        cardType: _selectedType,
        bankName: _bankNameController.text,
        balance: double.tryParse(_balanceController.text) ?? 0.0,
        creditLimit: _selectedType == CardType.credit
            ? double.tryParse(_creditLimitController.text)
            : null,
        cardColor: _selectedColor,
        createdAt: widget.card?.createdAt ?? DateTime.now(),
      );

      if (widget.card == null) {
        store.addCard(card);
      } else {
        store.updateCard(widget.card!.id, card);
      }

      context.pop();
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.card != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать карту' : 'Добавить карту'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCard,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Тип карты
              _buildCardTypeSection(),

              const SizedBox(height: 20),

              // Номер карты
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Номер карты',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                maxLength: 19, // 16 цифр + 3 пробела
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите номер карты';
                  }
                  final cleaned = value.replaceAll(' ', '');
                  if (cleaned.length != 16) {
                    return 'Номер карты должен содержать 16 цифр';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.length == 4 || value.length == 9 || value.length == 14) {
                    _cardNumberController.text = '$value ';
                    _cardNumberController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _cardNumberController.text.length),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              // Держатель карты
              TextFormField(
                controller: _cardHolderController,
                decoration: const InputDecoration(
                  labelText: 'Держатель карты',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите имя держателя карты';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Срок действия и CVV
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _selectExpiryDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Срок действия',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: '${_expiryDate.month.toString().padLeft(2, '0')}/${_expiryDate.year.toString().substring(2)}',
                          ),
                          validator: (value) {
                            if (_expiryDate.isBefore(DateTime.now())) {
                              return 'Срок действия истек';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length != 3) {
                          return 'CVV должен содержать 3 цифры';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Банк
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Банк',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название банка';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Баланс
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'Баланс',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  suffixText: '₽',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите баланс';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Введите корректную сумму';
                  }
                  return null;
                },
              ),

              // Кредитный лимит (только для кредитных карт)
              Observer(
                builder: (_) => _selectedType == CardType.credit
                    ? Column(
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _creditLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Кредитный лимит',
                        prefixIcon: Icon(Icons.credit_score),
                        suffixText: '₽',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите кредитный лимит';
                        }
                        final limit = double.tryParse(value);
                        if (limit == null || limit <= 0) {
                          return 'Введите корректный лимит';
                        }
                        return null;
                      },
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // Цвет карты
              _buildColorSelection(),

              const SizedBox(height: 30),

              // Кнопка сохранения
              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'Сохранить изменения' : 'Добавить карту'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Тип карты',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<CardType>(
          segments: const [
            ButtonSegment<CardType>(
              value: CardType.debit,
              label: Text('Дебетовая'),
              icon: Icon(Icons.account_balance_wallet),
            ),
            ButtonSegment<CardType>(
              value: CardType.credit,
              label: Text('Кредитная'),
              icon: Icon(Icons.credit_score),
            ),
            ButtonSegment<CardType>(
              value: CardType.prepaid,
              label: Text('Предоплаченная'),
              icon: Icon(Icons.card_giftcard),
            ),
          ],
          selected: {_selectedType},
          onSelectionChanged: (Set<CardType> newSelection) {
            setState(() {
              _selectedType = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Цвет карты',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CardColor.values.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(color.colorValue),
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedColor == color
                      ? Border.all(color: Colors.black, width: 3)
                      : null,
                ),
                child: _selectedColor == color
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}