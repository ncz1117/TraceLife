import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'model/diary.dart';
import 'repository/diary_repository_impl.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/mood_icon.dart';
import '../../shared/widgets/app_confirm_dialog.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_utils.dart';
import '../../core/services/image_service.dart';
import '../today/providers/today_providers.dart';
import '../stats/providers/stats_providers.dart';
import '../search/providers/search_providers.dart';
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
  List<String> _images = [];
  List<String> _initialImages = [];
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
      _mood != _initialMood ||
      !_listEquals(_images, _initialImages);

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _loadExisting() async {
    final repo = DiaryRepositoryImpl();
    final existing = await repo.getById(_existingId!);
    if (mounted) {
      setState(() {
        _dateStr = existing?.date ?? AppDateUtils.todayStr();
        _existingId = existing?.id;
        _controller.text = existing?.content ?? '';
        _mood = existing?.mood ?? 3;
        _images = List<String>.from(existing?.images ?? []);
        _initialContent = existing?.content ?? '';
        _initialMood = existing?.mood ?? 3;
        _initialImages = List<String>.from(existing?.images ?? []);
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    // 校验：日记内容或图片至少有一个（mood 永远有默认值 3，不检查）
    final hasContent = _controller.text.trim().isNotEmpty;
    final hasImages = _images.isNotEmpty;
    if (!hasContent && !hasImages) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日记不能是空的，加点内容或图片吧')),
      );
      return;
    }
    final repo = DiaryRepositoryImpl();
    final diary = Diary(
      id: _existingId,
      date: _dateStr,
      content: _controller.text,
      mood: _mood,
      images: _images,
    );
    await repo.save(diary);
    if (!mounted) return;
    ref.invalidate(todayDiariesProvider);
    ref.invalidate(diaryListProvider);
    ref.invalidate(diariesByMonthProvider);
    ref.invalidate(diariesByDateProvider(_dateStr));
    ref.invalidate(monthStatsProvider);
    ref.invalidate(moodTrendProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(dataSummaryProvider);
    ref.invalidate(searchResultsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('日记已保存')),
    );
    context.pop();
  }

  Future<void> _delete() async {
    if (_existingId == null) return;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '删除日记',
      message: '确定要删除这篇日记吗？',
    );
    if (confirmed && mounted) {
      // 先删本地图片文件（Native）
      for (final img in _images) {
        await ImageService.deleteImage(img);
      }
      await DiaryRepositoryImpl().delete(_existingId!);
      if (mounted) {
        ref.invalidate(todayDiariesProvider);
        ref.invalidate(diaryListProvider);
        ref.invalidate(diariesByMonthProvider);
        ref.invalidate(diariesByDateProvider(_dateStr));
        ref.invalidate(monthStatsProvider);
        ref.invalidate(moodTrendProvider);
        ref.invalidate(streakProvider);
        ref.invalidate(dataSummaryProvider);
        ref.invalidate(searchResultsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日记已删除')),
        );
        context.pop();
      }
    }
  }

  Future<void> _pickImage() async {
    if (_images.length >= ImageService.maxImagesPerDiary) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('最多 9 张图')),
      );
      return;
    }

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
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final List<String> picked;
      if (source == img_picker.ImageSource.gallery) {
        picked = await ImageService.pickFromGallery();
      } else {
        picked = await ImageService.pickFromCamera();
      }
      if (picked.isNotEmpty && mounted) {
        setState(() {
          _images = [..._images, ...picked];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('图片处理失败: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images = [..._images]..removeAt(index);
    });
    // 注：本地图片文件在保存时清理（不立即删，避免撤销逻辑复杂）
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isEdit = _existingId != null;

    Future<bool> onWillPop() async {
      if (!_hasUnsavedChanges) return true;
      final confirmed = await AppConfirmDialog.show(
        context,
        title: '放弃修改？',
        message: '你有未保存的修改，确定要离开吗？',
      );
      return confirmed;
    }

    return AppScaffold(
      title: AppDateUtils.formatDisplay(_dateStr),
      showBack: true,
      onWillPop: onWillPop,
      actions: [
        if (isEdit)
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
          const SizedBox(height: AppSpacing.sm),

          // 图片区
          if (_images.isNotEmpty || true) _buildImageStrip(),

          // 文字输入
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
                  icon: const Icon(Icons.check),
                  label: Text(isEdit ? '保存' : '写好了'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageStrip() {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          ..._images.asMap().entries.map((entry) {
            final index = entry.key;
            final img = entry.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _ImageThumbnail(stored: img, size: 64),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, size: 18),
                      color: Colors.red,
                      onPressed: () => _removeImage(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (_images.length < ImageService.maxImagesPerDiary)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_a_photo_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 图片缩略图 — 支持 data URI 和 Native 路径
class _ImageThumbnail extends StatelessWidget {
  final String stored;
  final double size;

  const _ImageThumbnail({required this.stored, this.size = 64});

  @override
  Widget build(BuildContext context) {
    if (stored.startsWith('data:')) {
      // base64 → Uint8List
      try {
        final base64Str = stored.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return _errorBox(context);
      }
    }
    // Native 路径
    return FutureBuilder<dynamic>(
      future: ImageService.resolveImageAsync(stored),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _loadingBox(context);
        }
        final file = snapshot.data;
        if (file == null) return _errorBox(context);
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _loadingBox(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _errorBox(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.broken_image),
    );
  }
}
