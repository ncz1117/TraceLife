import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../diary/model/diary.dart';
import '../../diary/repository/diary_repository_impl.dart';
import '../../day_counter/model/day_counter.dart';
import '../../day_counter/repository/day_counter_repository_impl.dart';
import '../../../core/utils/date_utils.dart';

final todayDiaryProvider = FutureProvider<Diary?>((ref) async {
  final repo = DiaryRepositoryImpl();
  return repo.getByDate(AppDateUtils.todayStr());
});

final todayCountersProvider = FutureProvider<List<DayCounter>>((ref) async {
  final repo = DayCounterRepositoryImpl();
  return repo.getAll();
});
