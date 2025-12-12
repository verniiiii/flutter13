import 'package:prac13/core/models/card_model.dart';
import 'package:prac13/data/models/dto/card_dto.dart';
import 'package:prac13/domain/entities/card_entity.dart';

class CardMapper {
  static CardDto toDto(CardModel model) {
    return CardDto(
      id: model.id,
      cardNumber: model.cardNumber,
      cardHolderName: model.cardHolderName,
      expiryDateMillis: model.expiryDate.millisecondsSinceEpoch,
      cvv: model.cvv,
      cardType: _cardTypeToString(model.cardType),
      bankName: model.bankName,
      balance: model.balance,
      creditLimit: model.creditLimit,
      cardColor: _cardColorToString(model.cardColor),
      isActive: model.isActive,
      createdAtMillis: model.createdAt.millisecondsSinceEpoch,
    );
  }

  static CardModel fromDto(CardDto dto) {
    return CardModel(
      id: dto.id,
      cardNumber: dto.cardNumber,
      cardHolderName: dto.cardHolderName,
      expiryDate: DateTime.fromMillisecondsSinceEpoch(dto.expiryDateMillis),
      cvv: dto.cvv,
      cardType: _stringToCardType(dto.cardType),
      bankName: dto.bankName,
      balance: dto.balance,
      creditLimit: dto.creditLimit,
      cardColor: _stringToCardColor(dto.cardColor),
      isActive: dto.isActive,
      createdAt: DateTime.fromMillisecondsSinceEpoch(dto.createdAtMillis),
    );
  }

  static CardEntity toEntity(CardModel model) {
    return CardEntity(
      id: model.id,
      cardNumber: model.cardNumber,
      cardHolderName: model.cardHolderName,
      expiryDate: model.expiryDate,
      cvv: model.cvv,
      cardType: model.cardType,
      bankName: model.bankName,
      balance: model.balance,
      creditLimit: model.creditLimit,
      cardColor: model.cardColor,
      isActive: model.isActive,
      createdAt: model.createdAt,
    );
  }

  static CardModel fromEntity(CardEntity entity) {
    return CardModel(
      id: entity.id,
      cardNumber: entity.cardNumber,
      cardHolderName: entity.cardHolderName,
      expiryDate: entity.expiryDate,
      cvv: entity.cvv,
      cardType: entity.cardType,
      bankName: entity.bankName,
      balance: entity.balance,
      creditLimit: entity.creditLimit,
      cardColor: entity.cardColor,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  static String _cardTypeToString(CardType type) {
    switch (type) {
      case CardType.debit:
        return 'debit';
      case CardType.credit:
        return 'credit';
      case CardType.prepaid:
        return 'prepaid';
    }
  }

  static CardType _stringToCardType(String str) {
    switch (str) {
      case 'debit':
        return CardType.debit;
      case 'credit':
        return CardType.credit;
      case 'prepaid':
        return CardType.prepaid;
      default:
        return CardType.debit;
    }
  }

  static String _cardColorToString(CardColor color) {
    switch (color) {
      case CardColor.blue:
        return 'blue';
      case CardColor.purple:
        return 'purple';
      case CardColor.green:
        return 'green';
      case CardColor.orange:
        return 'orange';
      case CardColor.red:
        return 'red';
      case CardColor.teal:
        return 'teal';
    }
  }

  static CardColor _stringToCardColor(String str) {
    switch (str) {
      case 'blue':
        return CardColor.blue;
      case 'purple':
        return CardColor.purple;
      case 'green':
        return CardColor.green;
      case 'orange':
        return CardColor.orange;
      case 'red':
        return CardColor.red;
      case 'teal':
        return CardColor.teal;
      default:
        return CardColor.blue;
    }
  }
}

