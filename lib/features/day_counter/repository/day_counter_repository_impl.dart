import '../../../../core/database/database_helper.dart';
import '../model/day_counter.dart';
import 'day_counter_repository.dart';

class DayCounterRepositoryImpl implements DayCounterRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  @override
  Future<List<DayCounter>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('day_counters', orderBy: 'sort_order ASC, created_at DESC');
    return maps.map((m) => DayCounter.fromDb(m)).toList();
  }

  @override
  Future<int> save(DayCounter counter) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    if (counter.id != null) {
      return db.update(
        'day_counters',
        counter.copyWith(createdAt: now).toDb(),
        where: 'id = ?',
        whereArgs: [counter.id],
      );
    }
    return db.insert('day_counters', counter.copyWith(createdAt: now).toDb());
  }

  @override
  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('day_counters', where: 'id = ?', whereArgs: [id]);
  }
}
