import 'package:sqflite/sqflite.dart';
import 'package:prac13/core/models/news_model.dart';
import 'package:prac13/data/datasources/local/app_database.dart';
import 'package:prac13/data/models/dto/news_dto.dart';
import 'package:prac13/data/models/mappers/news_mapper.dart';

class NewsLocalDataSource {
  NewsLocalDataSource();

  Future<Database> get _db => AppDatabase.database;

  Future<String> createNewsArticle(NewsArticle article) async {
    final db = await _db;
    final dto = NewsMapper.toDto(article);
    await db.insert(
      AppDatabase.newsTable,
      dto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return article.id;
  }

  Future<NewsArticle?> getNewsArticleById(String id) async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.newsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    final dto = NewsArticleDto.fromMap(maps.first);
    return NewsMapper.fromDto(dto);
  }

  Future<List<NewsArticle>> getAllNewsArticles() async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.newsTable,
      orderBy: 'published_at DESC',
    );

    return maps
        .map((map) => NewsArticleDto.fromMap(map))
        .map((dto) => NewsMapper.fromDto(dto))
        .toList();
  }

  Future<List<NewsArticle>> getNewsArticlesByCategory(NewsCategory category) async {
    final db = await _db;
    final categoryString = category == NewsCategory.finance
        ? 'finance'
        : category == NewsCategory.economy
        ? 'economy'
        : category == NewsCategory.crypto
        ? 'crypto'
        : category == NewsCategory.stocks
        ? 'stocks'
        : 'personal_finance';
    final maps = await db.query(
      AppDatabase.newsTable,
      where: 'category = ?',
      whereArgs: [categoryString],
      orderBy: 'published_at DESC',
    );

    return maps
        .map((map) => NewsArticleDto.fromMap(map))
        .map((dto) => NewsMapper.fromDto(dto))
        .toList();
  }

  Future<List<NewsArticle>> getUnreadNewsArticles() async {
    final db = await _db;
    final maps = await db.query(
      AppDatabase.newsTable,
      where: 'is_read = ?',
      whereArgs: [0],
      orderBy: 'published_at DESC',
    );

    return maps
        .map((map) => NewsArticleDto.fromMap(map))
        .map((dto) => NewsMapper.fromDto(dto))
        .toList();
  }

  Future<void> updateNewsArticle(NewsArticle article) async {
    final db = await _db;
    final dto = NewsMapper.toDto(article);
    await db.update(
      AppDatabase.newsTable,
      dto.toMap(),
      where: 'id = ?',
      whereArgs: [article.id],
    );
  }

  Future<void> markAsRead(String id) async {
    final article = await getNewsArticleById(id);
    if (article != null) {
      final updated = article.copyWith(isRead: true);
      await updateNewsArticle(updated);
    }
  }

  Future<void> deleteNewsArticle(String id) async {
    final db = await _db;
    await db.delete(
      AppDatabase.newsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllNewsArticles() async {
    final db = await _db;
    await db.delete(AppDatabase.newsTable);
  }
}