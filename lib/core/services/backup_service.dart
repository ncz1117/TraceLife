import 'dart:convert';
import '../database/database_helper.dart';

/// 平台无关的备份逻辑
class BackupService {
  const BackupService._();

  static Future<String> exportToJson() async {
    final db = DatabaseHelper.instance;
    final diaries = await db.query('diaries', orderBy: 'date ASC');
    final counters = await db.query('day_counters', orderBy: 'created_at ASC');
    final backup = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'app': 'TraceLife',
      'diaries': diaries,
      'day_counters': counters,
    };
    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  static Future<int> importFromJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final db = DatabaseHelper.instance;
    int count = 0;

    for (final diary in (data['diaries'] as List? ?? [])) {
      final d = diary as Map<String, dynamic>;
      if (d.containsKey('id') && d['id'] != null) {
        final existing = await db.query('diaries', where: 'id = ?', whereArgs: [d['id']]);
        if (existing.isEmpty) {
          await db.insert('diaries', d);
          count++;
        }
      }
    }

    for (final counter in (data['day_counters'] as List? ?? [])) {
      final c = counter as Map<String, dynamic>;
      if (c.containsKey('id') && c['id'] != null) {
        final existing = await db.query('day_counters', where: 'id = ?', whereArgs: [c['id']]);
        if (existing.isEmpty) {
          await db.insert('day_counters', c);
          count++;
        }
      }
    }
    return count;
  }
}
