import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/day_counter.dart';
import '../repository/day_counter_repository_impl.dart';

final dayCounterRepositoryProvider = Provider((ref) => DayCounterRepositoryImpl());

final dayCounterListProvider = FutureProvider<List<DayCounter>>((ref) async {
  return ref.read(dayCounterRepositoryProvider).getAll();
});
