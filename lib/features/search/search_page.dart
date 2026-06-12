import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/search_providers.dart';
import '../diary/model/diary.dart';
import '../day_counter/model/day_counter.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/mood_icon.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_utils.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchKeywordProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    ref.read(searchKeywordProvider.notifier).state = value;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final results = ref.watch(searchResultsProvider);

    return AppScaffold(
      title: '搜索',
      showBack: true,
      body: Column(
        children: [
          // 搜索框
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '搜索日记内容或纪念日标题',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _onSearch('');
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            onChanged: _onSearch,
            onSubmitted: _onSearch,
          ),
          const SizedBox(height: AppSpacing.md),

          // 搜索结果
          Expanded(
            child: results.when(
              data: (data) {
                if (data.keyword.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: colorScheme.outline),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '输入关键词开始搜索',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }
                if (data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: colorScheme.outline),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '没有找到 "${data.keyword}" 相关内容',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }
                return _buildResults(data);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('搜索失败: $e',
                    style: TextStyle(color: colorScheme.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchResults data) {
    return ListView(
      children: [
        if (data.diaries.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              '日记 (${data.diaries.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ...data.diaries.map((d) => _DiaryResultCard(diary: d, keyword: data.keyword)),
        ],
        if (data.counters.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              '纪念日 (${data.counters.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ...data.counters.map((c) => _CounterResultCard(counter: c)),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _DiaryResultCard extends StatelessWidget {
  final Diary diary;
  final String keyword;

  const _DiaryResultCard({required this.diary, required this.keyword});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push('/diary/edit', extra: diary.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              MoodIcon(mood: diary.mood, size: 32),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppDateUtils.formatDisplay(diary.date),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _highlightKeyword(diary.content, keyword),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterResultCard extends StatelessWidget {
  final DayCounter counter;

  const _CounterResultCard({required this.counter});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push('/day-counter/add', extra: counter),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Text(counter.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      counter.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      counter.displayDate,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

/// 简单关键词高亮
String _highlightKeyword(String text, String keyword) {
  if (keyword.trim().isEmpty) return text;
  final lowerText = text.toLowerCase();
  final lowerKeyword = keyword.toLowerCase();
  final index = lowerText.indexOf(lowerKeyword);
  if (index == -1) return text;
  // 截取包含关键词的片段
  final start = (index - 20).clamp(0, text.length);
  final end = (index + lowerKeyword.length + 30).clamp(0, text.length);
  final prefix = start > 0 ? '...' : '';
  final suffix = end < text.length ? '...' : '';
  return '$prefix${text.substring(start, end)}$suffix';
}
