import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;
  static bool _initialized = false;

  DatabaseHelper._();

  static void init() {
    if (!_initialized) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _initialized = true;
    }
  }

  Future<Database> get database async {
    // Ensure FFI is initialized before getting database
    init();
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Use temp directory for web, app documents for native
    final dir = kIsWeb
        ? '.'
        : await getDatabasesPath();
    final dbPath = p.join(dir, 'trace_life.db');
    debugPrint('Database path: $dbPath');

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS diaries (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        date       TEXT    NOT NULL UNIQUE,
        content    TEXT    NOT NULL DEFAULT '',
        mood       INTEGER NOT NULL DEFAULT 3 CHECK(mood >= 1 AND mood <= 5),
        created_at TEXT    NOT NULL,
        updated_at TEXT    NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_diaries_date ON diaries(date)',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS day_counters (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        target_date TEXT    NOT NULL,
        emoji       TEXT    NOT NULL DEFAULT '📅',
        color_index INTEGER NOT NULL DEFAULT 0,
        sort_order  INTEGER NOT NULL DEFAULT 0,
        created_at  TEXT    NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_day_counters_date ON day_counters(target_date)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
