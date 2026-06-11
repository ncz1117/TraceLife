import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'model/day_counter.dart';
import 'providers/day_counter_providers.dart';
import 'repository/day_counter_repository_impl.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_section_header.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_utils.dart';
import '../today/providers/today_providers.dart';

class DayCounterAddPage extends ConsumerStatefulWidget {
  const DayCounterAddPage({super.key});

  @override
  ConsumerState<DayCounterAddPage> createState() => _DayCounterAddPageState();
}

class _DayCounterAddPageState extends ConsumerState<DayCounterAddPage> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedEmoji = '🎉';

  static const _emojis = [
    '🎉', '❤️', '⭐', '🔥', '🎂', '🎄', '🌈', '🌟',
    '🎵', '📚', '✈️', '🏆', '💪', '🎯', '💎', '🌺',
  ];

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    final counter = DayCounter(
      title: _titleController.text.trim(),
      targetDate: '${_selectedDate.year}-'
          '${_selectedDate.month.toString().padLeft(2, '0')}-'
          '${_selectedDate.day.toString().padLeft(2, '0')}',
      emoji: _selectedEmoji,
    );
    await DayCounterRepositoryImpl().save(counter);
    if (mounted) {
      ref.invalidate(dayCounterListProvider);
      ref.invalidate(todayCountersProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已添加纪念日')),
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

    return AppScaffold(
      title: '添加纪念日',
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
          const SizedBox(height: AppSpacing.xl),
          const AppSectionHeader(title: '日期'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              AppDateUtils.formatDisplay(
                '${_selectedDate.year}-'
                '${_selectedDate.month.toString().padLeft(2, '0')}-'
                '${_selectedDate.day.toString().padLeft(2, '0')}',
              ),
            ),
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
              icon: const Icon(Icons.save_rounded),
              label: const Text('保存'),
            ),
          ),
        ],
      ),
    );
  }
}
