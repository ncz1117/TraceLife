import '../model/diary.dart';

abstract class DiaryRepository {
  Future<List<Diary>> getAll();
  Future<List<Diary>> getByDate(String date);
  Future<Diary?> getById(int id);
  Future<List<Diary>> getByMonth(int year, int month);
  Future<int> save(Diary diary);
  Future<int> delete(int id);
}
