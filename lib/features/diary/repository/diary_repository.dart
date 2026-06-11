import '../model/diary.dart';

abstract class DiaryRepository {
  Future<List<Diary>> getAll();
  Future<Diary?> getByDate(String date);
  Future<List<Diary>> getByMonth(int year, int month);
  Future<int> save(Diary diary);
  Future<int> delete(int id);
}
