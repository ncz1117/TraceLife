import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/diary.dart';
import '../repository/diary_repository_impl.dart';

final diaryRepositoryProvider = Provider((ref) => DiaryRepositoryImpl());

final diaryListProvider = FutureProvider<List<Diary>>((ref) async {
  return ref.read(diaryRepositoryProvider).getAll();
});

final diaryByDateProvider = FutureProvider.family<Diary?, String>((ref, date) async {
  return ref.read(diaryRepositoryProvider).getByDate(date);
});

final diaryByMonthProvider = FutureProvider.family<List<Diary>, Map<String, int>>((ref, params) async {
  return ref.read(diaryRepositoryProvider).getByMonth(
        params['year']!,
        params['month']!,
      );
});
