import 'package:flutter/foundation.dart';
import 'package:prac13/core/models/card_model.dart';

class CardsStore with ChangeNotifier {
  List<CardModel> _cards = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<CardModel> get cards => List.unmodifiable(_cards);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  List<CardModel> get activeCards =>
      _cards.where((card) => card.isActive).toList();

  List<CardModel> get creditCards =>
      _cards.where((card) => card.cardType == CardType.credit).toList();

  List<CardModel> get debitCards =>
      _cards.where((card) => card.cardType == CardType.debit).toList();

  double get totalBalance =>
      _cards.fold(0.0, (sum, card) => sum + card.balance);

  double get totalCreditLimit => creditCards.fold(
      0.0, (sum, card) => sum + (card.creditLimit ?? 0));

  double get totalAvailableCredit =>
      totalCreditLimit - creditCards.fold(0.0, (sum, card) => sum + card.balance);

  void addCard(CardModel card) {
    _cards.add(card);
    notifyListeners();
  }

  void updateCard(String id, CardModel updatedCard) {
    final index = _cards.indexWhere((card) => card.id == id);
    if (index != -1) {
      _cards[index] = updatedCard;
      notifyListeners();
    }
  }

  void deleteCard(String id) {
    _cards.removeWhere((card) => card.id == id);
    notifyListeners();
  }

  void toggleCardStatus(String id) {
    final index = _cards.indexWhere((card) => card.id == id);
    if (index != -1) {
      final card = _cards[index];
      _cards[index] = card.copyWith(isActive: !card.isActive);
      notifyListeners();
    }
  }

  CardModel? getCardById(String id) {
    try {
      return _cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Имитация загрузки данных (в реальном приложении будет API вызов)
  Future<void> loadCards() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Добавляем тестовые данные
      _cards.clear();
      _cards.addAll([
        CardModel(
          id: '1',
          cardNumber: '1234567812345678',
          cardHolderName: 'ИВАН ИВАНОВ',
          expiryDate: DateTime(2026, 12, 1),
          cvv: '123',
          cardType: CardType.debit,
          bankName: 'Тинькофф',
          balance: 15432.50,
          cardColor: CardColor.blue,
          createdAt: DateTime(2023, 1, 15),
        ),
        CardModel(
          id: '2',
          cardNumber: '8765432187654321',
          cardHolderName: 'ИВАН ИВАНОВ',
          expiryDate: DateTime(2025, 8, 1),
          cvv: '456',
          cardType: CardType.credit,
          bankName: 'Сбербанк',
          balance: 12500.00,
          creditLimit: 150000.00,
          cardColor: CardColor.green,
          createdAt: DateTime(2023, 3, 20),
        ),
        CardModel(
          id: '3',
          cardNumber: '5555666677778888',
          cardHolderName: 'ИВАН ИВАНОВ',
          expiryDate: DateTime(2024, 5, 1),
          cvv: '789',
          cardType: CardType.debit,
          bankName: 'Альфа-Банк',
          balance: 8300.75,
          cardColor: CardColor.orange,
          createdAt: DateTime(2023, 6, 10),
        ),
        CardModel(
          id: '4',
          cardNumber: '9999888877776666',
          cardHolderName: 'ИВАН ИВАНОВ',
          expiryDate: DateTime(2027, 3, 1),
          cvv: '321',
          cardType: CardType.credit,
          bankName: 'ВТБ',
          balance: 45000.00,
          creditLimit: 200000.00,
          cardColor: CardColor.purple,
          isActive: false,
          createdAt: DateTime(2023, 8, 5),
        ),
      ]);
    } catch (e) {
      _errorMessage = 'Ошибка загрузки карт: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Дополнительные полезные методы
  List<CardModel> getCardsByBank(String bankName) {
    return _cards.where((card) => card.bankName == bankName).toList();
  }

  List<CardModel> getExpiringCards({int monthsThreshold = 3}) {
    final now = DateTime.now();
    final thresholdDate = now.add(Duration(days: 30 * monthsThreshold));

    return _cards.where((card) =>
    card.expiryDate.isBefore(thresholdDate) &&
        card.expiryDate.isAfter(now)
    ).toList();
  }

  void sortCardsByBalance({bool ascending = true}) {
    _cards.sort((a, b) {
      if (ascending) {
        return a.balance.compareTo(b.balance);
      } else {
        return b.balance.compareTo(a.balance);
      }
    });
    notifyListeners();
  }

  void sortCardsByDate({bool ascending = true}) {
    _cards.sort((a, b) {
      if (ascending) {
        return a.createdAt.compareTo(b.createdAt);
      } else {
        return b.createdAt.compareTo(a.createdAt);
      }
    });
    notifyListeners();
  }
}