import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';

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

  static Future<void> exportToFile() async {
    final json = await exportToJson();
    final tmpDir = kIsWeb ? Directory('') : Directory.systemTemp;
    final file = File('${tmpDir.path}/trace_life_backup.json');
    await file.writeAsString(json);
    await Share.shareXFiles([XFile(file.path)], subject: '迹录数据备份');
  }

  static Future<int> importFromJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final db = DatabaseHelper.instance;
    int count = 0;

    final diaries = data['diaries'] as List? ?? [];
    for (final diary in diaries) {
      final d = diary as Map<String, dynamic>;
      if (d.containsKey('id') && d['id'] != null) {
        final existing = await db.query('diaries', where: 'id = ?', whereArgs: [d['id']]);
        if (existing.isEmpty) {
          await db.insert('diaries', d);
          count++;
        }
      }
    }

    final counters = data['day_counters'] as List? ?? [];
    for (final counter in counters) {
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
