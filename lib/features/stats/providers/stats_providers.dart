import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';

class DailyMood {
  final DateTime date;
  final double? mood; // null = 没写日记

  const DailyMood({required this.date, this.mood});
}

class MonthStats {
  final int year;
  final int month;
  final int diaryCount;
  final double? avgMood;
  final int totalWords; // 字符数
  final Map<int, int> dailyCount; // 日 → 篇数（热力图用）

  const MonthStats({
    required this.year,
    required this.month,
    required this.diaryCount,
    required this.avgMood,
    required this.totalWords,
    required this.dailyCount,
  });
}

/// 最近 7 天心情趋势
final moodTrendProvider = FutureProvider<List<DailyMood>>((ref) async {
  final db = DatabaseHelper.instance;
  final today = DateTime.now();
  final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6));
  final startStr = _formatDate(start);
  final endStr = _formatDate(today.add(const Duration(days: 1)));

  final rows = await db.query(
    'diaries',
    where: 'date >= ? AND date < ?',
    whereArgs: [startStr, endStr],
    orderBy: 'date ASC',
  );

  // 聚合每天的平均心情
  final byDate = <String, List<int>>{};
  for (final row in rows) {
    final date = row['date'] as String;
    final mood = row['mood'] as int;
    byDate.putIfAbsent(date, () => []).add(mood);
  }

  // 填充 7 天
  final result = <DailyMood>[];
  for (int i = 0; i < 7; i++) {
    final day = start.add(Duration(days: i));
    final dateStr = _formatDate(day);
    final moods = byDate[dateStr];
    if (moods != null && moods.isNotEmpty) {
      final avg = moods.reduce((a, b) => a + b) / moods.length;
      result.add(DailyMood(date: day, mood: avg));
    } else {
      result.add(DailyMood(date: day));
    }
  }
  return result;
});

/// 当前月统计
final monthStatsProvider = FutureProvider.family<MonthStats, DateTime>((ref, month) async {
  final db = DatabaseHelper.instance;
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1);
  final startStr = _formatDate(start);
  final endStr = _formatDate(end);

  final rows = await db.query(
    'diaries',
    where: 'date >= ? AND date < ?',
    whereArgs: [startStr, endStr],
    orderBy: 'date ASC',
  );

  if (rows.isEmpty) {
    return MonthStats(
      year: month.year,
      month: month.month,
      diaryCount: 0,
      avgMood: null,
      totalWords: 0,
      dailyCount: {},
    );
  }

  int totalMood = 0;
  int totalWords = 0;
  final dailyCount = <int, int>{};

  for (final row in rows) {
    totalMood += row['mood'] as int;
    totalWords += (row['content'] as String).length;
    final date = DateTime.parse(row['date'] as String);
    dailyCount[date.day] = (dailyCount[date.day] ?? 0) + 1;
  }

  return MonthStats(
    year: month.year,
    month: month.month,
    diaryCount: rows.length,
    avgMood: totalMood / rows.length,
    totalWords: totalWords,
    dailyCount: dailyCount,
  );
});

/// 连续写日记天数
final streakProvider = FutureProvider<int>((ref) async {
  final db = DatabaseHelper.instance;
  final today = DateTime.now();
  final todayStr = _formatDate(today);

  // 拿最近 365 天的日记日期
  final start = today.subtract(const Duration(days: 365));
  final startStr = _formatDate(start);
  final rows = await db.query(
    'diaries',
    columns: ['date'],
    where: 'date >= ? AND date <= ?',
    whereArgs: [startStr, todayStr],
    orderBy: 'date DESC',
  );

  // 唯一日期集合
  final dates = <String>{};
  for (final row in rows) {
    dates.add(row['date'] as String);
  }

  if (dates.isEmpty) return 0;

  // 从今天往前数连续天数
  int streak = 0;
  var cursor = today;
  while (dates.contains(_formatDate(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
});

String _formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// 概览数据 — 设置页用
class DataSummary {
  final int totalDiaries;
  final int totalCounters;
  final DateTime? firstDiaryDate;
  final DateTime? latestDiaryDate;

  const DataSummary({
    required this.totalDiaries,
    required this.totalCounters,
    required this.firstDiaryDate,
    required this.latestDiaryDate,
  });
}

final dataSummaryProvider = FutureProvider<DataSummary>((ref) async {
  final db = DatabaseHelper.instance;
  // 全部查出来然后聚合（数据量小够用）
  final allDiaries = await db.query('diaries', orderBy: 'date ASC');
  final allCounters = await db.query('day_counters');

  DateTime? first;
  DateTime? latest;
  if (allDiaries.isNotEmpty) {
    first = DateTime.parse(allDiaries.first['date'] as String);
    latest = DateTime.parse(allDiaries.last['date'] as String);
  }

  return DataSummary(
    totalDiaries: allDiaries.length,
    totalCounters: allCounters.length,
    firstDiaryDate: first,
    latestDiaryDate: latest,
  );
});
