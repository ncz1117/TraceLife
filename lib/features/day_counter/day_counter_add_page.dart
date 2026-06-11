import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'model/day_counter.dart';
import 'providers/day_counter_providers.dart';
import 'repository/day_counter_repository_impl.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_section_header.dart';
import '../../core/theme/app_spacing.dart';
import '../today/providers/today_providers.dart';

class DayCounterAddPage extends ConsumerStatefulWidget {
  final DayCounter? counter; // null = add, non-null = edit

  const DayCounterAddPage({super.key, this.counter});

  @override
  ConsumerState<DayCounterAddPage> createState() => _DayCounterAddPageState();
}

class _DayCounterAddPageState extends ConsumerState<DayCounterAddPage> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedEmoji = '🎉';
  int _counterType = CounterType.countdown;
  bool get _isEdit => widget.counter != null;

  static const _emojis = [
    '🎉', '❤️', '⭐', '🔥', '🎂', '🎄', '🌈', '🌟',
    '🎵', '📚', '✈️', '🏆', '💪', '🎯', '💎', '🌺',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final c = widget.counter!;
      _titleController.text = c.title;
      _selectedEmoji = c.emoji;
      _counterType = c.counterType;
      if (c.counterType == CounterType.countdown) {
        _selectedDate = DateTime.parse(c.targetDate);
      } else {
        // 生日模式：取今年
        final parts = c.targetDate.split('-');
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        _selectedDate = DateTime(DateTime.now().year, month, day);
      }
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    String targetDate;
    if (_counterType == CounterType.birthday) {
      targetDate = '${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    } else {
      targetDate = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    }

    final counter = DayCounter(
      id: widget.counter?.id,
      title: _titleController.text.trim(),
      targetDate: targetDate,
      counterType: _counterType,
      emoji: _selectedEmoji,
    );
    await DayCounterRepositoryImpl().save(counter);
    if (mounted) {
      ref.invalidate(dayCounterListProvider);
      ref.invalidate(todayCountersProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? '已更新' : '已添加')),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBirthday = _counterType == CounterType.birthday;

    return AppScaffold(
      title: _isEdit ? '编辑纪念日' : '添加纪念日',
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '事件名称',
              hintText: '例如：认识你',
            ),
            autofocus: true,
          ),
          const SizedBox(height: AppSpacing.md),

          // 类型切换
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('纪念日')),
              ButtonSegment(value: 1, label: Text('生日')),
            ],
            selected: {_counterType},
            onSelectionChanged: (v) => setState(() => _counterType = v.first),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 日期
          const AppSectionHeader(title: '日期'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(isBirthday
                ? '${_selectedDate.month}月${_selectedDate.day}日'
                : '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日'),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2050),
                locale: const Locale('zh'),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
          ),
          if (isBirthday)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                '生日模式仅保存月日，每年自动计算到下一次的剩余天数',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),

          const AppSectionHeader(title: '表情'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _emojis.map((emoji) {
              final isSelected = _selectedEmoji == emoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primaryContainer : null,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: isSelected
                        ? Border.all(color: colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _save,
              icon: Icon(_isEdit ? Icons.check_rounded : Icons.save_rounded),
              label: Text(_isEdit ? '更新' : '保存'),
            ),
          ),
        ],
      ),
    );
  }
}
