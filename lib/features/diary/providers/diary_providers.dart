import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/diary.dart';
import '../repository/diary_repository_impl.dart';

final diaryRepositoryProvider = Provider((ref) => DiaryRepositoryImpl());

final diaryListProvider = FutureProvider<List<Diary>>((ref) async {
  return ref.read(diaryRepositoryProvider).getAll();
});

/// 某一天的所有日记
final diariesByDateProvider = FutureProvider.family<List<Diary>, String>((ref, date) async {
  return ref.read(diaryRepositoryProvider).getByDate(date);
});

/// 某个月的日记（用于日历标记）
final diariesByMonthProvider = FutureProvider.family<List<Diary>, Map<String, int>>((ref, params) async {
  return ref.read(diaryRepositoryProvider).getByMonth(
        params['year']!,
        params['month']!,
      );
});
