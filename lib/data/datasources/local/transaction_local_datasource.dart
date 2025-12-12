import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:prac13/core/models/transaction_model.dart';
import 'package:prac13/data/datasources/local/app_database.dart';
import 'package:prac13/data/models/dto/transaction_dto.dart';
import 'package:prac13/data/models/mappers/transaction_mapper.dart';

class TransactionLocalDataSource {
  TransactionLocalDataSource();

  Future<Database> get _db => AppDatabase.database;

  Future<String> createTransaction(Transaction transaction) async {
    final db = await _db;
    final dto = TransactionMapper.toDto(transaction);
    await db.insert(
      AppDatabase.transactionsTable,
      dto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return transaction.id;
  }

  Future<Transaction?> getTransactionById(String id) async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    final dto = TransactionDto.fromMap(maps.first);
    return TransactionMapper.fromDto(dto);
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.transactionsTable,
      orderBy: 'created_at DESC',
    );

    return maps
        .map((map) => TransactionDto.fromMap(map))
        .map((dto) => TransactionMapper.fromDto(dto))
        .toList();
  }

  Future<List<Transaction>> getTransactionsByType(String type) async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.transactionsTable,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'created_at DESC',
    );

    return maps
        .map((map) => TransactionDto.fromMap(map))
        .map((dto) => TransactionMapper.fromDto(dto))
        .toList();
  }

  Future<List<Transaction>> getTransactionsByCategory(String category) async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.transactionsTable,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );

    return maps
        .map((map) => TransactionDto.fromMap(map))
        .map((dto) => TransactionMapper.fromDto(dto))
        .toList();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await _db;
    final dto = TransactionMapper.toDto(transaction);
    await db.update(
      AppDatabase.transactionsTable,
      dto.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await _db;
    await db.delete(
      AppDatabase.transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllTransactions() async {
    final db = await _db;
    await db.delete(AppDatabase.transactionsTable);
  }
}