import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class AppDatabase {
  static bool _initialized = false;

  /// Инициализация databaseFactory для Windows/Linux/macOS
  static Future<void> initialize() async {
    if (_initialized) return;

    // Инициализируем FFI для десктопных платформ
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      databaseFactory = databaseFactoryFfi;
    }

    _initialized = true;
  }
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
    // Убеждаемся, что databaseFactory инициализирован
    await initialize();

    String dbPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Для десктопных платформ используем текущую директорию
      final directory = Directory.current;
      dbPath = join(directory.path, _databaseName);
    } else {
      // Для мобильных платформ используем стандартный путь
      dbPath = join(await getDatabasesPath(), _databaseName);
    }

    return await openDatabase(
      dbPath,
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
    await initialize();

    String dbPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final directory = Directory.current;
      dbPath = join(directory.path, _databaseName);
    } else {
      dbPath = join(await getDatabasesPath(), _databaseName);
    }

    await databaseFactory.deleteDatabase(dbPath);
    _database = null;
  }
}

