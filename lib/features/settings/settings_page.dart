import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/error_boundary.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_presets.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/downloader.dart';
import '../../core/services/theme_controller.dart';
import '../../core/providers/notification_providers.dart';
import '../stats/providers/stats_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final summaryAsync = ref.watch(dataSummaryProvider);

    return AppScaffold(
      title: '设置',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // 数据概览卡
          summaryAsync.when(
            data: (s) => _buildSummaryCard(context, s),
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text('加载失败: $e'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── 导航 ──
          _buildSectionHeader(context, '功能', colorScheme.primary),
          const SizedBox(height: AppSpacing.sm),
          _buildNavTile(
            context,
            icon: Icons.search,
            title: '搜索',
            subtitle: '搜索日记和纪念日',
            onTap: () => context.push('/search'),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildNavTile(
            context,
            icon: Icons.bar_chart_rounded,
            title: '数据统计',
            subtitle: '心情趋势、月报、热力图',
            onTap: () => context.push('/stats'),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── 主题 ──
          _buildSectionHeader(context, '主题', colorScheme.primary),
          const SizedBox(height: AppSpacing.sm),
          _buildThemePresetsCard(context, ref),
          const SizedBox(height: AppSpacing.sm),
          _buildBrightnessCard(context, ref),
          const SizedBox(height: AppSpacing.xl),

          // ── 通知 ──
          _buildSectionHeader(context, '通知提醒', colorScheme.primary),
          const SizedBox(height: AppSpacing.sm),
          _buildNotificationCard(context, ref),
          const SizedBox(height: AppSpacing.xl),

          // ── 数据管理 ──
          _buildSectionHeader(context, '数据管理', colorScheme.primary),
          const SizedBox(height: AppSpacing.sm),
          _buildExportButton(context),
          const SizedBox(height: AppSpacing.sm),
          _buildImportButton(context, ref),
          const SizedBox(height: AppSpacing.xl),

          // ── 关于 ──
          _buildSectionHeader(context, '关于', colorScheme.primary),
          const SizedBox(height: AppSpacing.sm),
          _buildAboutTile(context, '版本', '1.0.0'),
          _buildAboutTile(context, '构建者', 'ncz1117'),
          _buildAboutTile(context, '技术栈', 'Flutter + Riverpod + SQLite'),
          _buildAboutTile(
            context,
            'GitHub',
            'github.com/ncz1117/TraceLife',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text, Color color) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
    );
  }

  Widget _buildSummaryCard(BuildContext context, DataSummary s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                icon: Icons.book_rounded,
                label: '日记',
                value: '${s.totalDiaries}',
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: _SummaryItem(
                icon: Icons.celebration_rounded,
                label: '纪念日',
                value: '${s.totalCounters}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// 4 套主题预设（2x2 grid）
  Widget _buildThemePresetsCard(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeControllerProvider).preset;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.6,
          children: ThemePreset.values
              .map((p) => _ThemePresetTile(
                    preset: p,
                    selected: p == current,
                    onTap: () => ref.read(themeControllerProvider.notifier).setPreset(p),
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// 明暗模式（system / light / dark）
  Widget _buildBrightnessCard(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider).mode;
    return Card(
      child: Column(
        children: [
          _BrightnessTile(
            label: '跟随系统',
            icon: Icons.brightness_auto_rounded,
            selected: mode == ThemeMode.system,
            onTap: () => ref.read(themeControllerProvider.notifier).setMode(ThemeMode.system),
          ),
          const Divider(height: 1),
          _BrightnessTile(
            label: '浅色',
            icon: Icons.light_mode_rounded,
            selected: mode == ThemeMode.light,
            onTap: () => ref.read(themeControllerProvider.notifier).setMode(ThemeMode.light),
          ),
          const Divider(height: 1),
          _BrightnessTile(
            label: '深色',
            icon: Icons.dark_mode_rounded,
            selected: mode == ThemeMode.dark,
            onTap: () => ref.read(themeControllerProvider.notifier).setMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.file_upload_outlined),
        title: const Text('导出数据'),
        subtitle: const Text('导出为 JSON 文件到本地'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          try {
            final json = await BackupService.exportToJson();
            final fileName =
                'trace_life_backup_${DateTime.now().millisecondsSinceEpoch}.json';
            downloadJson(json, fileName);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ 数据已导出')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ErrorBoundary.showError(context, '导出失败: $e');
            }
          }
        },
      ),
    );
  }

  Widget _buildImportButton(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.file_download_outlined),
        title: const Text('导入数据'),
        subtitle: const Text('从 JSON 文件恢复数据'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          try {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['json'],
            );
            if (result == null || result.files.isEmpty) return;

            final file = result.files.single;
            final json = kIsWeb
                ? String.fromCharCodes(file.bytes ?? [])
                : await File(file.path!).readAsString();
            final count = await BackupService.importFromJson(json);

            // 失效所有相关 provider
            ref.invalidate(dataSummaryProvider);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ 已导入 $count 条新记录')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ErrorBoundary.showError(context, '导入失败: $e');
            }
          }
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 总开关
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('启用提醒'),
              subtitle: Text(
                kIsWeb
                    ? '⚠️ 仅手机端支持推送'
                    : settings.enabled
                        ? '将在纪念日前自动通知'
                        : '关闭',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              value: settings.enabled,
              onChanged: (v) async {
                if (kIsWeb) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('推送仅在手机端生效')),
                  );
                  return;
                }
                await notifier.setEnabled(v);
              },
            ),

            if (settings.enabled) ...[
              const Divider(),

              // 提前天数
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('提前几天提醒'),
                trailing: DropdownButton<int>(
                  value: settings.daysBefore,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 天')),
                    DropdownMenuItem(value: 3, child: Text('3 天')),
                    DropdownMenuItem(value: 7, child: Text('7 天')),
                  ],
                  onChanged: (v) {
                    if (v != null) notifier.setDaysBefore(v);
                  },
                ),
              ),

              // 提醒时间
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('提醒时间'),
                trailing: TextButton(
                  child: Text('${settings.hour.toString().padLeft(2, '0')}:00'),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: settings.hour,
                        minute: 0,
                      ),
                    );
                    if (picked != null) {
                      await notifier.setHour(picked.hour);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                )),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
      ],
    );
  }
}

/// 主题预设 tile（4 选 1）
class _ThemePresetTile extends StatelessWidget {
  final ThemePreset preset;
  final bool selected;
  final VoidCallback onTap;
  const _ThemePresetTile({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final preview = ColorScheme.fromSeed(
      seedColor: preset.seed,
      brightness: Theme.of(context).brightness,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? preview.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: selected ? preview.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4 色色板预览
            Row(
              children: [
                _ColorChip(color: preview.primary),
                const SizedBox(width: 4),
                _ColorChip(color: preview.secondary),
                const SizedBox(width: 4),
                _ColorChip(color: preview.tertiary),
                const SizedBox(width: 4),
                _ColorChip(color: preview.surface),
                const Spacer(),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: preview.primary, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              preset.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected
                        ? preview.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              preset.tagline,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected
                        ? preview.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final Color color;
  const _ColorChip({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
    );
  }
}

/// 明暗模式 tile
class _BrightnessTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _BrightnessTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
