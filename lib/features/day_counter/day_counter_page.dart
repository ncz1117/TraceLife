import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'model/day_counter.dart';
import 'providers/day_counter_providers.dart';
import 'repository/day_counter_repository_impl.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_confirm_dialog.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_utils.dart';

class DayCounterPage extends ConsumerWidget {
  const DayCounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countersAsync = ref.watch(dayCounterListProvider);

    return countersAsync.when(
      data: (counters) {
        if (counters.isEmpty) {
          return AppEmptyState(
            icon: Icons.celebration_outlined,
            message: '还没有纪念日',
            actionLabel: '添加一个',
            onAction: () => context.push('/day-counter/add'),
          );
        }
        return _buildList(context, ref, counters);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('加载失败')),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<DayCounter> counters) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: counters.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final counter = counters[index];
          final days = counter.daysPassed.abs();
          final label = counter.isFuture ? '剩余' : '已过';

          return AppCard(
            onTap: () async {
              final confirmed = await AppConfirmDialog.show(
                context,
                title: '删除纪念日',
                message: '确定要删除「${counter.title}」吗？',
              );
              if (confirmed && context.mounted) {
                final repo = DayCounterRepositoryImpl();
                if (counter.id != null) {
                  await repo.delete(counter.id!);
                  ref.invalidate(dayCounterListProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已删除')),
                    );
                  }
                }
              }
            },
            child: Row(
              children: [
                Text(counter.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(counter.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        AppDateUtils.formatDisplay(counter.targetDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$days',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/day-counter/add'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
