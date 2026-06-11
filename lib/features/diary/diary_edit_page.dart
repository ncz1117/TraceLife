import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'model/diary.dart';
import 'repository/diary_repository_impl.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/mood_icon.dart';
import '../../shared/widgets/app_confirm_dialog.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_utils.dart';
import '../today/providers/today_providers.dart';
import 'providers/diary_providers.dart';

/// extra: String 日期 → 新建；int id → 编辑已有
class DiaryEditPage extends ConsumerStatefulWidget {
  final dynamic extra;

  const DiaryEditPage({super.key, this.extra});

  @override
  ConsumerState<DiaryEditPage> createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends ConsumerState<DiaryEditPage> {
  final _controller = TextEditingController();
  int _mood = 3;
  String _dateStr = '';
  bool _isLoading = true;
  String _initialContent = '';
  int _initialMood = 3;
  int? _existingId;

  @override
  void initState() {
    super.initState();
    if (widget.extra is int) {
      _existingId = widget.extra as int;
      _loadExisting();
    } else {
      _dateStr = (widget.extra as String?) ?? AppDateUtils.todayStr();
      _isLoading = false;
    }
  }

  bool get _hasUnsavedChanges =>
      _controller.text != _initialContent ||
      _mood != _initialMood;

  Future<void> _loadExisting() async {
    final repo = DiaryRepositoryImpl();
    final existing = await repo.getById(_existingId!);
    if (mounted) {
      setState(() {
        _dateStr = existing?.date ?? AppDateUtils.todayStr();
        _existingId = existing?.id;
        _controller.text = existing?.content ?? '';
        _mood = existing?.mood ?? 3;
        _initialContent = existing?.content ?? '';
        _initialMood = existing?.mood ?? 3;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    final repo = DiaryRepositoryImpl();
    final diary = Diary(
      id: _existingId,
      date: _dateStr,
      content: _controller.text,
      mood: _mood,
    );
    await repo.save(diary);
    if (mounted) {
      ref.invalidate(todayDiariesProvider);
      ref.invalidate(diaryListProvider);
      ref.invalidate(diariesByMonthProvider);
      ref.invalidate(diariesByDateProvider(_dateStr));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日记已保存')),
      );
      context.pop();
    }
  }

  Future<void> _delete() async {
    if (_existingId == null) return;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '删除日记',
      message: '确定要删除这篇日记吗？',
    );
    if (confirmed && mounted) {
      await DiaryRepositoryImpl().delete(_existingId!);
      if (mounted) {
        ref.invalidate(todayDiariesProvider);
        ref.invalidate(diaryListProvider);
        ref.invalidate(diariesByMonthProvider);
        ref.invalidate(diariesByDateProvider(_dateStr));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日记已删除')),
        );
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isEdit = _existingId != null;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!_hasUnsavedChanges) return;
        final confirmed = await AppConfirmDialog.show(
          context,
          title: '放弃修改？',
          message: '你有未保存的修改，确定要离开吗？',
        );
        if (confirmed && context.mounted) {
          context.pop();
        }
      },
      child: AppScaffold(
      title: AppDateUtils.formatDisplay(_dateStr),
      showBack: true,
      actions: [
        if (isEdit)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
      ],
      body: Column(
        children: [
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(isEdit ? '更新' : '保存'),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
