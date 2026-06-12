import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/today_providers.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_section_header.dart';
import '../../core/theme/app_spacing.dart';
import 'widgets/daily_greeting.dart';
import 'widgets/diary_preview_card.dart';
import 'widgets/counter_card.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayDiariesAsync = ref.watch(todayDiariesProvider);
    final todayCountersAsync = ref.watch(todayCountersProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            const Expanded(child: DailyGreeting()),
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: '数据统计',
              onPressed: () => context.push('/stats'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // 纪念日卡片区域
        AppSectionHeader(
          title: '纪念日',
          actionLabel: '查看全部',
          onAction: () => context.go('/day-counter'),
        ),
        todayCountersAsync.when(
          data: (counters) => counters.isEmpty
              ? AppEmptyState(
                  icon: Icons.celebration_outlined,
                  message: '还没有纪念日',
                  actionLabel: '添加一个',
                  onAction: () => context.push('/day-counter/add'),
                )
              : SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: counters.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (_, i) => CounterCard(counter: counters[i]),
                  ),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: AppSpacing.xl),

        // 今日日记区域
        AppSectionHeader(
          title: '今日日记',
          actionLabel: '写日记',
          onAction: () => context.push('/diary/edit', extra: null),
        ),
        todayDiariesAsync.when(
          data: (diaries) {
            if (diaries.isEmpty) {
              return AppEmptyState(
                icon: Icons.edit_note_rounded,
                message: '今天还没有日记',
                actionLabel: '记录今天',
                onAction: () => context.push('/diary/edit', extra: null),
              );
            }
            return Column(
              children: diaries.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: DiaryPreviewCard(diary: d),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
