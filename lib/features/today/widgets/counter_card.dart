import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../day_counter/model/day_counter.dart';

class CounterCard extends StatelessWidget {
  final DayCounter counter;

  const CounterCard({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final days = counter.daysPassed.abs();
    final label = counter.isFuture ? '剩余' : '已过';

    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(counter.emoji, style: const TextStyle(fontSize: 20)),
                  const Spacer(),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$days',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '天',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                    ),
              ),
              const Spacer(),
              Text(
                counter.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
