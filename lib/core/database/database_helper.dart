import 'dart:io';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getDatabasesPath();
    final path = '$dir${Platform.pathSeparator}trace_life.db';
    return openDatabase(
      path,
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 未来版本迁移
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
