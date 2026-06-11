import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_section_header.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_utils.dart';

class DayCounterAddPage extends StatefulWidget {
  const DayCounterAddPage({super.key});

  @override
  State<DayCounterAddPage> createState() => _DayCounterAddPageState();
}

class _DayCounterAddPageState extends State<DayCounterAddPage> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedEmoji = '🎉';

  static const _emojis = [
    '🎉', '❤️', '⭐', '🔥', '🎂', '🎄', '🌈', '🌟',
    '🎵', '📚', '✈️', '🏆', '💪', '🎯', '💎', '🌺',
  ];

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已添加纪念日（假数据模式）')),
    );
    context.pop();
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
