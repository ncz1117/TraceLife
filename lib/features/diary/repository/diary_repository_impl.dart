import '../../../core/database/database_helper.dart';
import '../model/diary.dart';
import 'diary_repository.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  @override
  Future<List<Diary>> getAll() async {
    final maps = await _db.query('diaries', orderBy: 'date DESC, created_at DESC');
    return maps.map((m) => DiaryMapper.fromDb(m)).toList();
  }

  @override
  Future<List<Diary>> getByDate(String date) async {
    final maps = await _db.query(
      'diaries',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'created_at ASC',
    );
    return maps.map((m) => DiaryMapper.fromDb(m)).toList();
  }

  @override
  Future<Diary?> getById(int id) async {
    final maps = await _db.query(
      'diaries',
      where: 'id = ?',
      whereArgs: [id],
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
      orderBy: 'date ASC, created_at ASC',
    );
    return maps.map((m) => DiaryMapper.fromDb(m)).toList();
  }

  @override
  Future<int> save(Diary diary) async {
    final now = DateTime.now().toIso8601String();
    if (diary.id != null) {
      return _db.update(
        'diaries',
        diary.copyWith(updatedAt: now).toDb(),
        where: 'id = ?',
        whereArgs: [diary.id],
      );
    }
    // 新日记：不再按日期去重，每篇都是新记录
    return _db.insert('diaries', diary.copyWith(createdAt: now, updatedAt: now).toDb());
  }

  @override
  Future<int> delete(int id) async {
    return _db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }
}
