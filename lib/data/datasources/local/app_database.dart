import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static const String _databaseName = 'prac12.db';
  static const int _databaseVersion = 1;

  // Таблицы
  static const String transactionsTable = 'transactions';
  static const String cardsTable = 'cards';
  static const String motivationsTable = 'motivations';
  static const String newsTable = 'news';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Таблица транзакций
    await db.execute('''
      CREATE TABLE $transactionsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        created_at INTEGER NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    // Таблица карт
    await db.execute('''
      CREATE TABLE $cardsTable (
        id TEXT PRIMARY KEY,
        card_number TEXT NOT NULL,
        card_holder_name TEXT NOT NULL,
        expiry_date INTEGER NOT NULL,
        cvv TEXT NOT NULL,
        card_type TEXT NOT NULL,
        bank_name TEXT NOT NULL,
        balance REAL NOT NULL,
        credit_limit REAL,
        card_color TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    // Таблица мотивационного контента
    await db.execute('''
      CREATE TABLE $motivationsTable (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        author TEXT,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Таблица новостей
    await db.execute('''
      CREATE TABLE $newsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        summary TEXT NOT NULL,
        content TEXT,
        image_url TEXT,
        category TEXT NOT NULL,
        source TEXT NOT NULL,
        published_at INTEGER NOT NULL,
        url TEXT,
        is_read INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Здесь можно добавить логику миграций при изменении версии БД
    if (oldVersion < newVersion) {
      // Пример миграции:
      // await db.execute('ALTER TABLE transactions ADD COLUMN new_field TEXT');
    }
  }

  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  static Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}

