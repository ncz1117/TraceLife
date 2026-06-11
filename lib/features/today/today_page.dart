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
    final todayDiary = ref.watch(todayDiaryProvider);
    final todayCounters = ref.watch(todayCountersProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // 问候
        const DailyGreeting(),
        const SizedBox(height: AppSpacing.xl),

        // 纪念日卡片区域
        AppSectionHeader(
          title: '纪念日',
          actionLabel: '查看全部',
          onAction: () => context.go('/day-counter'),
        ),
        if (todayCounters.isEmpty)
          AppEmptyState(
            icon: Icons.celebration_outlined,
            message: '还没有纪念日',
            actionLabel: '添加一个',
            onAction: () => context.push('/day-counter/add'),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: todayCounters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) =>
                  CounterCard(counter: todayCounters[index]),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),

        // 今日日记区域
        const AppSectionHeader(title: '今日日记'),
        if (todayDiary != null)
          DiaryPreviewCard(diary: todayDiary)
        else
          AppEmptyState(
            icon: Icons.edit_note_rounded,
            message: '今天还没有日记',
            actionLabel: '记录今天',
            onAction: () => context.push('/diary/edit', extra: null),
          ),
      ],
    );
  }
}
