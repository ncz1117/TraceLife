import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// 跨平台数据库抽象层
/// - Native (Android/iOS): 使用 sqflite SQLite
/// - Web: 使用内存 Map（开发调试，不持久化）
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _nativeDb;
  static final Map<String, List<Map<String, dynamic>>> _memoryDb = {};
  static bool _isInitialized = false;
  static bool _isWeb = false;

  DatabaseHelper._();

  static Future<void> init() async {
    if (_isInitialized) return;
    _isWeb = kIsWeb;
    if (!_isWeb) {
      _nativeDb = await _initNative();
    }
    _initMemory();
    _isInitialized = true;
  }

  // ── Native SQLite ──

  static Future<Database> _initNative() async {
    final dir = await getDatabasesPath();
    final dbPath = '$dir${Platform.pathSeparator}trace_life.db';
    return openDatabase(dbPath, version: 3, onCreate: _onCreateNative, onUpgrade: _onUpgradeNative);
  }

  static Future<void> _onCreateNative(Database db, int version) async {
    for (final sql in _tableDDL(version)) {
      await db.execute(sql);
    }
  }

  static Future<void> _onUpgradeNative(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE day_counters ADD COLUMN counter_type INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      // 移除 diaries.date 的 UNIQUE 约束，支持一天多篇日记
      await db.execute('CREATE TABLE diaries_new (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, content TEXT NOT NULL DEFAULT \'\', mood INTEGER NOT NULL DEFAULT 3 CHECK(mood >= 1 AND mood <= 5), created_at TEXT NOT NULL, updated_at TEXT NOT NULL)');
      await db.execute('INSERT INTO diaries_new SELECT * FROM diaries');
      await db.execute('DROP TABLE diaries');
      await db.execute('ALTER TABLE diaries_new RENAME TO diaries');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_diaries_date ON diaries(date)');
    }
  }

  // ── Memory DB ──

  static void _initMemory() {
    for (final table in ['diaries', 'day_counters']) {
      _memoryDb[table] = [];
    }
    _memoryNextId = {'diaries': 1, 'day_counters': 1};
  }

  static Map<String, int> _memoryNextId = {};

  // ── DDL ──

  static List<String> _tableDDL(int version) => [
    'CREATE TABLE IF NOT EXISTS diaries (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, content TEXT NOT NULL DEFAULT \'\', mood INTEGER NOT NULL DEFAULT 3 CHECK(mood >= 1 AND mood <= 5), created_at TEXT NOT NULL, updated_at TEXT NOT NULL)',
    'CREATE INDEX IF NOT EXISTS idx_diaries_date ON diaries(date)',
    'CREATE TABLE IF NOT EXISTS day_counters (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, target_date TEXT NOT NULL, counter_type INTEGER NOT NULL DEFAULT 0, emoji TEXT NOT NULL DEFAULT \'📅\', color_index INTEGER NOT NULL DEFAULT 0, sort_order INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL)',
    'CREATE INDEX IF NOT EXISTS idx_day_counters_date ON day_counters(target_date)',
  ];

  // ── Public API ──

  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    if (_isWeb) {
      return _memoryQuery(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
    }
    return _nativeDb!.query(table,
        columns: columns, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    if (_isWeb) return _memoryInsert(table, values);
    return _nativeDb!.insert(table, values);
  }

  Future<int> update(String table, Map<String, dynamic> values,
      {String? where, List<Object?>? whereArgs}) async {
    if (_isWeb) return _memoryUpdate(table, values, where: where, whereArgs: whereArgs);
    return _nativeDb!.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    if (_isWeb) return _memoryDelete(table, where: where, whereArgs: whereArgs);
    return _nativeDb!.delete(table, where: where, whereArgs: whereArgs);
  }

  // ── Memory Implementation ──

  List<Map<String, dynamic>> _memoryQuery(String table, {String? where, List<Object?>? whereArgs, String? orderBy}) {
    var rows = List<Map<String, dynamic>>.from(_memoryDb[table] ?? []);
    if (where != null) {
      // 简单等值过滤
      final parts = where.split(' = ');
      if (parts.length == 2 && whereArgs != null && whereArgs.isNotEmpty) {
        final col = parts[0].trim();
        final val = whereArgs.first;
        rows = rows.where((r) => r[col] == val).toList();
      }
      // 范围过滤 (>= AND <)
      final rangeMatch = RegExp(r'(\w+) >= \? AND (\w+) < \?').firstMatch(where);
      if (rangeMatch != null && whereArgs != null && whereArgs.length >= 2) {
        final col = rangeMatch.group(1)!;
        final start = whereArgs[0] as String;
        final end = whereArgs[1] as String;
        rows = rows.where((r) {
          final v = r[col] as String;
          return v.compareTo(start) >= 0 && v.compareTo(end) < 0;
        }).toList();
      }
    }
    if (orderBy != null) {
      final desc = orderBy.endsWith(' DESC');
      final col = orderBy.replaceAll(' DESC', '').replaceAll(' ASC', '').trim();
      rows.sort((a, b) {
        final av = a[col] as Comparable;
        final bv = b[col] as Comparable;
        return desc ? bv.compareTo(av) : av.compareTo(bv);
      });
    }
    return rows;
  }

  int _memoryInsert(String table, Map<String, dynamic> values) {
    final id = _memoryNextId[table]!;
    _memoryNextId[table] = id + 1;
    final row = Map<String, dynamic>.from(values);
    row['id'] = id;
    _memoryDb[table]!.add(row);
    return id;
  }

  int _memoryUpdate(String table, Map<String, dynamic> values,
      {String? where, List<Object?>? whereArgs}) {
    int count = 0;
    final rows = _memoryQuery(table, where: where, whereArgs: whereArgs);
    for (final row in rows) {
      row.addAll(values);
      count++;
    }
    return count;
  }

  int _memoryDelete(String table, {String? where, List<Object?>? whereArgs}) {
    final before = _memoryDb[table]!.length;
    final toRemove = _memoryQuery(table, where: where, whereArgs: whereArgs);
    _memoryDb[table]!.removeWhere((r) => toRemove.contains(r));
    return before - _memoryDb[table]!.length;
  }

  Future<void> close() async {
    if (!_isWeb && _nativeDb != null) {
      _nativeDb!.close();
      _nativeDb = null;
    }
  }
}
