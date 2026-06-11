import '../model/day_counter.dart';

abstract class DayCounterRepository {
  Future<List<DayCounter>> getAll();
  Future<int> save(DayCounter counter);
  Future<int> delete(int id);
}
