import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'model/diary.dart';
import 'providers/diary_providers.dart';

class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  String _dateToStr(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final monthDiariesAsync = ref.watch(diariesByMonthProvider({
      'year': _focusedDay.year,
      'month': _focusedDay.month,
    }));
    final selectedDiariesAsync = ref.watch(diariesByDateProvider(_dateToStr(_selectedDay)));

    final diaryDates = monthDiariesAsync.valueOrNull
            ?.map((d) => d.date)
            .toSet() ?? {};

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() => _focusedDay = focusedDay);
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              final dateStr = _dateToStr(day);
              if (diaryDates.contains(dateStr)) {
                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
          locale: 'zh_CN',
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        const Divider(height: 1),

        // 选中日期的日记列表
        Expanded(
          child: selectedDiariesAsync.when(
            data: (diaries) => _buildDiaryList(context, diaries),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _emptyDay(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDiaryList(BuildContext context, List<Diary> diaries) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              '共 ${diaries.length} 篇日记',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: () {
                final dateStr = _dateToStr(_selectedDay);
                context.push('/diary/edit', extra: dateStr);
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('写日记'),
            ),
          ],
        ),
        if (diaries.isEmpty)
          _emptyDay(context)
        else
          ...diaries.map((diary) => _diaryTile(context, diary)),
      ],
    );
  }

  Widget _diaryTile(BuildContext context, Diary diary) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/diary/edit', extra: diary.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    ['😢', '😟', '😐', '😊', '😄'][diary.mood.clamp(1, 5) - 1],
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ['很差', '不好', '一般', '不错', '很好'][diary.mood.clamp(1, 5) - 1],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    diary.createdAt != null
                        ? diary.createdAt!.substring(11, 16)
                        : '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                diary.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyDay(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_note_rounded,
              size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            '这天还没有日记',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () {
              final dateStr = _dateToStr(_selectedDay);
              context.push('/diary/edit', extra: dateStr);
            },
            icon: const Icon(Icons.edit_rounded),
            label: const Text('写日记'),
          ),
        ],
      ),
    );
  }
}
