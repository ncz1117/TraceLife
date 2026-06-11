import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/error_boundary.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/downloader.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: '设置',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('数据管理',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  )),
          const SizedBox(height: AppSpacing.md),
          _buildExportButton(context),
          const SizedBox(height: AppSpacing.sm),
          _buildImportButton(context),
          const Divider(height: AppSpacing.xxl),
          Text('关于',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  )),
          const SizedBox(height: AppSpacing.sm),
          _buildAboutTile(context, '版本', '1.0.0'),
          _buildAboutTile(context, '构建者', 'ncz1117'),
          _buildAboutTile(context, '技术栈', 'Flutter + Riverpod + SQLite'),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.file_upload_outlined),
        title: const Text('导出数据'),
        subtitle: const Text('将日记和纪念日导出为 JSON 文件到本地'),
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

  Widget _buildImportButton(BuildContext context) {
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
