import 'package:flutter_riverpod/flutter_riverpod.dart';

// 假数据 Model — Phase 5 替换为 freezed Diary
class FakeDiaryEntry {
  final String date;
  final String content;
  final int mood;
  const FakeDiaryEntry(this.date, this.content, this.mood);
}

// 假数据仓库
const _fakeDiaries = [
  FakeDiaryEntry('2026-07-10', '今天项目立项了，把技术栈定了下来。\nFlutter + Riverpod + sqflite。', 5),
  FakeDiaryEntry('2026-07-09', '看了几个开源项目，Omnix 的设计不错。\n决定自己做一款生活记录 App。', 4),
  FakeDiaryEntry('2026-07-11', '开始写前端骨架，Phase 3 完成了 Today 首页。', 4),
];

// 日记列表（全部）
final diaryListProvider = Provider<List<FakeDiaryEntry>>((ref) {
  return _fakeDiaries;
});

// 按月份筛选
final diaryByMonthProvider = Provider.family<List<FakeDiaryEntry>, Map<String, int>>((ref, params) {
  final year = params['year']!;
  final month = params['month']!;
  return _fakeDiaries.where((d) {
    final parts = d.date.split('-');
    return int.parse(parts[0]) == year && int.parse(parts[1]) == month;
  }).toList();
});
