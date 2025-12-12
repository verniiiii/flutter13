import '../entities/card_entity.dart';

abstract class CardRepository {
  Future<List<CardEntity>> getCards();
  Future<CardEntity?> getCardById(String id);
  Future<void> addCard(CardEntity card);
  Future<void> updateCard(CardEntity card);
  Future<void> deleteCard(String id);
  Future<List<CardEntity>> getActiveCards();
  Future<List<CardEntity>> getCreditCards();
  Future<List<CardEntity>> getDebitCards();
}

