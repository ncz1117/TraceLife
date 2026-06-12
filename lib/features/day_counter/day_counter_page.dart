import 'dart:convert' show base64Decode;
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'model/day_counter.dart';
import 'providers/day_counter_providers.dart';
import 'repository/day_counter_repository_impl.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_confirm_dialog.dart';
import '../../core/services/image_service.dart';
import '../../core/services/notification_service.dart';
import '../../shared/extensions/context_extensions.dart';
import '../../core/theme/app_spacing.dart';

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
          final days = counter.daysUntil;
          final label = counter.labelText;
          final isBirthday = counter.counterType == CounterType.birthday;
          final hasImage = counter.image.isNotEmpty;

          return AppCard(
            onTap: () => context.push('/day-counter/view', extra: counter.id),
            onLongPress: () => _showActions(context, ref, counter),
            child: Row(
              children: [
                // 封面缩略图或 emoji
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: _ListImage(stored: counter.image),
                    ),
                  )
                else
                  Text(counter.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(counter.title,
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                          if (isBirthday)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '生日',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        counter.displayDate,
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

  void _showActions(BuildContext context, WidgetRef ref, DayCounter counter) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/day-counter/add', extra: counter);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: context.appColors.danger),
              title: Text('删除', style: TextStyle(color: context.appColors.danger)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed = await AppConfirmDialog.show(
                  context,
                  title: '删除纪念日',
                  message: '确定要删除「${counter.title}」吗？',
                );
                if (confirmed && context.mounted) {
                  final repo = DayCounterRepositoryImpl();
                  if (counter.id != null) {
                    if (counter.image.isNotEmpty) {
                      await ImageService.deleteImage(counter.image);
                    }
                    await repo.delete(counter.id!);
                    // 取消该纪念日的推送
                    if (counter.id != null) {
                      await NotificationService.cancelCounterNotification(
                          counter.id!);
                    }
                    ref.invalidate(dayCounterListProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已删除')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 列表缩略图 — 支持 base64 (Web) 和 Native 路径
class _ListImage extends StatelessWidget {
  final String stored;
  const _ListImage({required this.stored});

  @override
  Widget build(BuildContext context) {
    if (stored.startsWith('data:')) {
      try {
        final base64Str = stored.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(context),
        );
      } catch (_) {
        return _fallback(context);
      }
    }
    return FutureBuilder<dynamic>(
      future: ImageService.resolveImageAsync(stored),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == null) {
          return _fallback(context);
        }
        return Image.file(
          snapshot.data as File,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(context),
        );
      },
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.image_outlined, size: 20)),
    );
  }
}
