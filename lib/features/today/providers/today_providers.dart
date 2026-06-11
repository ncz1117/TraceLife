import 'package:flutter_riverpod/flutter_riverpod.dart';

// 假数据 — 后续 Phase 5 替换为 SQLite
class FakeDiary {
  final String date;
  final String content;
  final int mood;
  const FakeDiary(this.date, this.content, this.mood);
}

class FakeCounter {
  final String title;
  final String targetDate;
  final String emoji;
  const FakeCounter(this.title, this.targetDate, this.emoji);

  int get daysPassed {
    final target = DateTime.parse(targetDate);
    return DateTime.now().difference(target).inDays;
  }

  bool get isFuture => daysPassed < 0;
}

// 假日记
final todayDiaryProvider = Provider<FakeDiary?>((ref) {
  // 模拟：今天有日记
  return const FakeDiary('2026-07-11', '今天开始学习 Flutter，搭好了项目骨架。'
      'AppSpacing 间距系统很好用，MD3 配色也舒服。'
      '明天继续做日记模块。', 4);
});

// 假正数日列表
final todayCountersProvider = Provider<List<FakeCounter>>((ref) {
  return const [
    FakeCounter('认识你', '2026-06-01', '❤️'),
    FakeCounter('项目立项', '2026-07-10', '🚀'),
    FakeCounter('暑假开始', '2026-07-01', '🌞'),
  ];
});
