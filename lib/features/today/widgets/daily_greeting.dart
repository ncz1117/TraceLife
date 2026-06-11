import 'package:flutter/material.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_spacing.dart';

class DailyGreeting extends StatelessWidget {
  const DailyGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? '早上好'
        : hour < 18
            ? '下午好'
            : '晚上好';
    final dateStr = '${now.year}年${now.month}月${now.day}日';
    final weekday = AppDateUtils.formatWeekday(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$dateStr $weekday',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
