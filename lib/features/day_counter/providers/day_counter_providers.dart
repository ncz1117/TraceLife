import 'package:flutter_riverpod/flutter_riverpod.dart';

// 假数据 — Phase 6 替换为 SQLite
class FakeDayCounter {
  final String title;
  final String targetDate;
  final String emoji;

  const FakeDayCounter(this.title, this.targetDate, this.emoji);

  int get daysPassed {
    final target = DateTime.parse(targetDate);
    return DateTime.now().difference(target).inDays;
  }

  bool get isFuture => daysPassed < 0;
}

// 与 Today 页保持一致的假数据
const _fakeCounters = [
  FakeDayCounter('认识你', '2026-06-01', '❤️'),
  FakeDayCounter('项目立项', '2026-07-10', '🚀'),
  FakeDayCounter('暑假开始', '2026-07-01', '🌞'),
];

final dayCounterListProvider = Provider<List<FakeDayCounter>>((ref) {
  return _fakeCounters;
});
