import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/mood_icon.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../diary/model/diary.dart';

class DiaryPreviewCard extends StatelessWidget {
  final Diary diary;

  const DiaryPreviewCard({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final preview = diary.content.length > 80
        ? '${diary.content.substring(0, 80)}...'
        : diary.content;

    return AppCard(
      onTap: () => context.push('/diary/edit', extra: diary.date),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MoodIcon(mood: diary.mood, size: 20),
              const Spacer(),
              Text(
                AppDateUtils.formatDisplay(diary.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            preview.isEmpty ? '（空白日记）' : preview,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '点击查看或编辑',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
