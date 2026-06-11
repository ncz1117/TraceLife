import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/today_providers.dart';

class CounterCard extends StatelessWidget {
  final FakeCounter counter;

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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(counter.emoji, style: const TextStyle(fontSize: 24)),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$days',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '天',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Text(
                counter.title,
                style: Theme.of(context).textTheme.labelLarge,
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
