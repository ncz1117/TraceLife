import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../diary/model/diary.dart';
import '../../day_counter/model/day_counter.dart';
import '../../../core/database/database_helper.dart';

class SearchResults {
  final List<Diary> diaries;
  final List<DayCounter> counters;
  final String keyword;

  const SearchResults({
    required this.diaries,
    required this.counters,
    required this.keyword,
  });

  bool get isEmpty => diaries.isEmpty && counters.isEmpty;
  int get total => diaries.length + counters.length;
}

final searchKeywordProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<SearchResults>((ref) async {
  final keyword = ref.watch(searchKeywordProvider).trim();
  if (keyword.isEmpty) {
    return const SearchResults(diaries: [], counters: [], keyword: '');
  }

  final db = DatabaseHelper.instance;
  final diaryRows = await db.search('diaries', keyword);
  final counterRows = await db.search('day_counters', keyword);

  final diaries = diaryRows.map(DiaryMapper.fromDb).toList();
  final counters = counterRows.map(DayCounter.fromDb).toList();

  return SearchResults(
    diaries: diaries,
    counters: counters,
    keyword: keyword,
  );
});
