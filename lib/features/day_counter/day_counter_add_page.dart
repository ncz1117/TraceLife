import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'dart:convert' show base64Decode;
import 'model/day_counter.dart';
import 'providers/day_counter_providers.dart';
import 'repository/day_counter_repository_impl.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_section_header.dart';
import '../../shared/widgets/app_confirm_dialog.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/image_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/providers/notification_providers.dart';
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
  String _image = ''; // 封面图路径或 data URI
  bool get _isEdit => widget.counter != null;

  // 初始值，用于判断是否有未保存修改
  String _initialTitle = '';
  DateTime _initialDate = DateTime.now();
  String _initialEmoji = '🎉';
  int _initialType = CounterType.countdown;
  String _initialImage = '';

  bool get _hasUnsavedChanges {
    if (_counterType != _initialType) return true;
    if (_selectedEmoji != _initialEmoji) return true;
    if (_titleController.text != _initialTitle) return true;
    if (_image != _initialImage) return true;
    if (_selectedDate.year != _initialDate.year ||
        _selectedDate.month != _initialDate.month ||
        _selectedDate.day != _initialDate.day) return true;
    return false;
  }

  Future<bool> onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '放弃修改？',
      message: '你有未保存的修改，确定要离开吗？',
    );
    return confirmed;
  }

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
      _image = c.image;
      if (c.counterType == CounterType.countdown) {
        _selectedDate = DateTime.parse(c.targetDate);
      } else {
        final parts = c.targetDate.split('-');
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        _selectedDate = DateTime(DateTime.now().year, month, day);
      }
    }
    _initialTitle = _titleController.text;
    _initialDate = _selectedDate;
    _initialEmoji = _selectedEmoji;
    _initialType = _counterType;
    _initialImage = _image;
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    String targetDate;
    if (_counterType == CounterType.birthday) {
      targetDate =
          '${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    } else {
      targetDate =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    }

    final counter = DayCounter(
      id: widget.counter?.id,
      title: _titleController.text.trim(),
      targetDate: targetDate,
      counterType: _counterType,
      emoji: _selectedEmoji,
      image: _image,
    );
    await DayCounterRepositoryImpl().save(counter);
    // 调度本地推送（仅在开关开启时）
    final notifEnabled = ref.read(notificationSettingsProvider).enabled;
    if (notifEnabled) {
      final settings = ref.read(notificationSettingsProvider);
      await NotificationService.scheduleCounterNotification(
        counter: counter,
        daysBefore: settings.daysBefore,
        hour: settings.hour,
      );
    }
    if (mounted) {
      ref.invalidate(dayCounterListProvider);
      ref.invalidate(todayCountersProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? '已更新' : '已添加')),
      );
      context.pop();
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<img_picker.ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(ctx, img_picker.ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(ctx, img_picker.ImageSource.camera),
            ),
            if (_image.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('移除封面图', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(ctx, null),
              ),
          ],
        ),
      ),
    );
    if (source == null && _image.isEmpty) return;
    if (source == null) {
      setState(() => _image = '');
      return;
    }
    try {
      final List<String> picked;
      if (source == img_picker.ImageSource.gallery) {
        picked = await ImageService.pickFromGallery();
      } else {
        picked = await ImageService.pickFromCamera();
      }
      if (picked.isNotEmpty && mounted) {
        setState(() => _image = picked.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片处理失败: $e')),
        );
      }
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
      onWillPop: onWillPop,
      body: ListView(
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

          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('纪念日')),
              ButtonSegment(value: 1, label: Text('生日')),
            ],
            selected: {_counterType},
            onSelectionChanged: (v) => setState(() => _counterType = v.first),
          ),
          const SizedBox(height: AppSpacing.xl),

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
          const SizedBox(height: AppSpacing.xl),

          // 封面图
          const AppSectionHeader(title: '封面图（可选）'),
          GestureDetector(
            onTap: _pickImage,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  border: Border.all(color: colorScheme.outline),
                ),
                child: _image.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 40,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '点我选图',
                            style: TextStyle(
                                color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          _CoverImage(stored: _image),
                          // 右下角"更换"小标签
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '更换',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 80),

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

/// 封面图渲染 — 支持 base64 (Web) 和 Native 路径
class _CoverImage extends StatelessWidget {
  final String stored;
  const _CoverImage({required this.stored});

  @override
  Widget build(BuildContext context) {
    if (stored.startsWith('data:')) {
      try {
        final base64Str = stored.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _errorBox(context),
        );
      } catch (_) {
        return _errorBox(context);
      }
    }
    return FutureBuilder<dynamic>(
      future: ImageService.resolveImageAsync(stored),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == null) {
          return _loadingBox(context);
        }
        return Image.file(
          snapshot.data,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _errorBox(context),
        );
      },
    );
  }

  Widget _errorBox(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.broken_image)),
    );
  }

  Widget _loadingBox(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
