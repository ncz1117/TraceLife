import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/diary_providers.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/mood_icon.dart';
import '../../shared/widgets/app_confirm_dialog.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_utils.dart';

class DiaryEditPage extends ConsumerStatefulWidget {
  final String? date;

  const DiaryEditPage({super.key, this.date});

  @override
  ConsumerState<DiaryEditPage> createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends ConsumerState<DiaryEditPage> {
  final _controller = TextEditingController();
  int _mood = 3;
  String _dateStr = '';

  @override
  void initState() {
    super.initState();
    _dateStr = widget.date ?? AppDateUtils.todayStr();
    _loadExisting();
  }

  void _loadExisting() {
    // 假数据：查找已有日记
    final diaries = ref.read(diaryListProvider);
    final existing = diaries.where((d) => d.date == _dateStr).firstOrNull;
    if (existing != null) {
      _controller.text = existing.content;
      _mood = existing.mood;
    }
  }

  void _save() {
    // 假数据保存：仅提示成功
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('日记已保存（假数据模式）')),
    );
    context.pop();
  }

  void _delete() async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '删除日记',
      message: '确定要删除这篇日记吗？',
    );
    if (confirmed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日记已删除（假数据模式）')),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppDateUtils.formatDisplay(_dateStr),
      showBack: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: _delete,
        ),
      ],
      body: Column(
        children: [
          // 心情选择
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final mood = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _mood = mood),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _mood == mood
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MoodIcon(mood: mood, size: 32),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 日记输入
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: '记录今天...',
                border: InputBorder.none,
                filled: false,
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          // 保存按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('保存'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
