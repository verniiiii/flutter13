import 'package:sqflite/sqflite.dart';
import 'package:prac13/core/models/motivation_model.dart';
import 'package:prac13/data/datasources/local/app_database.dart';
import 'package:prac13/data/models/dto/motivation_dto.dart';
import 'package:prac13/data/models/mappers/motivation_mapper.dart';

class MotivationLocalDataSource {
  MotivationLocalDataSource();

  Future<Database> get _db => AppDatabase.database;

  Future<String> createMotivation(MotivationContent motivation) async {
    final db = await _db;
    final dto = MotivationMapper.toDto(motivation);
    await db.insert(
      AppDatabase.motivationsTable,
      dto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return motivation.id;
  }

  Future<MotivationContent?> getMotivationById(String id) async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.motivationsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    final dto = MotivationDto.fromMap(maps.first);
    return MotivationMapper.fromDto(dto);
  }

  Future<List<MotivationContent>> getAllMotivations() async {
    final db = await _db;
    final maps = await db.query(AppDatabase.motivationsTable);

    return maps
        .map((map) => MotivationDto.fromMap(map))
        .map((dto) => MotivationMapper.fromDto(dto))
        .toList();
  }

  Future<List<MotivationContent>> getMotivationsByType(ContentType type) async {
    final db = await _db;
    final typeString = type == ContentType.quote
        ? 'quote'
        : type == ContentType.affirmation
        ? 'affirmation'
        : 'tip';
    final maps = await db.query(
      AppDatabase.motivationsTable,
      where: 'type = ?',
      whereArgs: [typeString],
    );

    return maps
        .map((map) => MotivationDto.fromMap(map))
        .map((dto) => MotivationMapper.fromDto(dto))
        .toList();
  }

  Future<List<MotivationContent>> getFavoriteMotivations() async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.motivationsTable,
      where: 'is_favorite = ?',
      whereArgs: [1],
    );

    return maps
        .map((map) => MotivationDto.fromMap(map))
        .map((dto) => MotivationMapper.fromDto(dto))
        .toList();
  }

  Future<void> updateMotivation(MotivationContent motivation) async {
    final db = await _db;
    final dto = MotivationMapper.toDto(motivation);
    await db.update(
      AppDatabase.motivationsTable,
      dto.toMap(),
      where: 'id = ?',
      whereArgs: [motivation.id],
    );
  }

  Future<void> toggleFavorite(String id) async {
    final motivation = await getMotivationById(id);
    if (motivation != null) {
      final updated = motivation.copyWith(isFavorite: !motivation.isFavorite);
      await updateMotivation(updated);
    }
  }

  Future<void> deleteMotivation(String id) async {
    final db = await _db;
    await db.delete(
      AppDatabase.motivationsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllMotivations() async {
    final db = await _db;
    await db.delete(AppDatabase.motivationsTable);
  }
}