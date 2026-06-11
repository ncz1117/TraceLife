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
    final todayDiaryAsync = ref.watch(todayDiaryProvider);
    final todayCountersAsync = ref.watch(todayCountersProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const DailyGreeting(),
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
        const AppSectionHeader(title: '今日日记'),
        todayDiaryAsync.when(
          data: (diary) => diary != null
              ? DiaryPreviewCard(diary: diary)
              : AppEmptyState(
                  icon: Icons.edit_note_rounded,
                  message: '今天还没有日记',
                  actionLabel: '记录今天',
                  onAction: () => context.push('/diary/edit', extra: null),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
