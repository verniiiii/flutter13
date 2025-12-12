import 'package:sqflite/sqflite.dart';
import 'package:prac13/core/models/card_model.dart';
import 'package:prac13/data/datasources/local/app_database.dart';
import 'package:prac13/data/models/dto/card_dto.dart';
import 'package:prac13/data/models/mappers/card_mapper.dart';

class CardLocalDataSource {
  CardLocalDataSource();

  Future<Database> get _db => AppDatabase.database;

  Future<String> createCard(CardModel card) async {
    final db = await _db;
    final dto = CardMapper.toDto(card);
    await db.insert(
      AppDatabase.cardsTable,
      dto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return card.id;
  }

  Future<CardModel?> getCardById(String id) async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.cardsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    final dto = CardDto.fromMap(maps.first);
    return CardMapper.fromDto(dto);
  }

  Future<List<CardModel>> getAllCards() async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.cardsTable,
      orderBy: 'created_at DESC',
    );

    return maps
        .map((map) => CardDto.fromMap(map))
        .map((dto) => CardMapper.fromDto(dto))
        .toList();
  }

  Future<List<CardModel>> getActiveCards() async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.cardsTable,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );

    return maps
        .map((map) => CardDto.fromMap(map))
        .map((dto) => CardMapper.fromDto(dto))
        .toList();
  }

  Future<void> updateCard(CardModel card) async {
    final db = await _db;
    final dto = CardMapper.toDto(card);
    await db.update(
      AppDatabase.cardsTable,
      dto.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(String id) async {
    final db = await _db;
    await db.delete(
      AppDatabase.cardsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllCards() async {
    final db = await _db;
    await db.delete(AppDatabase.cardsTable);
  }
}