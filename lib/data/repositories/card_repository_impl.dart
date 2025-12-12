import '../../domain/repositories/card_repository.dart';
import '../../domain/entities/card_entity.dart';
import '../datasources/local/card_local_datasource.dart';
import '../../core/models/card_model.dart';

class CardRepositoryImpl implements CardRepository {
  final CardLocalDataSource localDataSource;

  CardRepositoryImpl(this.localDataSource);

  CardEntity _modelToEntity(CardModel model) {
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

  CardModel _entityToModel(CardEntity entity) {
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

  @override
  Future<List<CardEntity>> getCards() async {
    final models = await localDataSource.getAllCards();
    return models.map(_modelToEntity).toList();
  }

  @override
  Future<CardEntity?> getCardById(String id) async {
    final model = await localDataSource.getCardById(id);
    return model != null ? _modelToEntity(model) : null;
  }

  @override
  Future<void> addCard(CardEntity card) async {
    await localDataSource.createCard(_entityToModel(card));
  }

  @override
  Future<void> updateCard(CardEntity card) async {
    await localDataSource.updateCard(_entityToModel(card));
  }

  @override
  Future<void> deleteCard(String id) async {
    await localDataSource.deleteCard(id);
  }

  @override
  Future<List<CardEntity>> getActiveCards() async {
    final all = await getCards();
    return all.where((c) => c.isActive).toList();
  }

  @override
  Future<List<CardEntity>> getCreditCards() async {
    final all = await getCards();
    return all.where((c) => c.isCreditCard).toList();
  }

  @override
  Future<List<CardEntity>> getDebitCards() async {
    final all = await getCards();
    return all.where((c) => !c.isCreditCard).toList();
  }
}

