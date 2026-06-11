import '../../../core/database/database_helper.dart';
import '../model/diary.dart';
import 'diary_repository.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  @override
  Future<List<Diary>> getAll() async {
    final maps = await _db.query('diaries', orderBy: 'date DESC');
    return maps.map((m) => DiaryMapper.fromDb(m)).toList();
  }

  @override
  Future<Diary?> getByDate(String date) async {
    final maps = await _db.query(
      'diaries',
      where: 'date = ?',
      whereArgs: [date],
    );
    if (maps.isEmpty) return null;
    return DiaryMapper.fromDb(maps.first);
  }

  @override
  Future<List<Diary>> getByMonth(int year, int month) async {
    final start = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';
    final end = month == 12
        ? '${year + 1}-01-01'
        : '${year.toString().padLeft(4, '0')}-${(month + 1).toString().padLeft(2, '0')}-01';
    final maps = await _db.query(
      'diaries',
      where: 'date >= ? AND date < ?',
      whereArgs: [start, end],
      orderBy: 'date ASC',
    );
    return maps.map((m) => DiaryMapper.fromDb(m)).toList();
  }

  @override
  Future<int> save(Diary diary) async {
    final now = DateTime.now().toIso8601String();
    final existing = await getByDate(diary.date);
    if (existing != null) {
      return _db.update(
        'diaries',
        diary.copyWith(id: existing.id, updatedAt: now).toDb(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
    return _db.insert('diaries', diary.copyWith(createdAt: now, updatedAt: now).toDb());
  }

  @override
  Future<int> delete(int id) async {
    return _db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }
}
