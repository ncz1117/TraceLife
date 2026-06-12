import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:convert' show base64Decode;
import 'dart:io' show File;
import 'model/day_counter.dart';
import 'providers/day_counter_providers.dart';
import '../../core/services/image_service.dart';
import '../../shared/widgets/app_scaffold.dart';

/// 纪念日查看页
/// 背景图 + 大字倒计时 + 右上角编辑按钮
class DayCounterViewPage extends ConsumerStatefulWidget {
  final int counterId;
  const DayCounterViewPage({super.key, required this.counterId});

  @override
  ConsumerState<DayCounterViewPage> createState() => _DayCounterViewPageState();
}

class _DayCounterViewPageState extends ConsumerState<DayCounterViewPage> {
  DayCounter? _counter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ref.read(dayCounterListProvider.future);
    final found = list.where((c) => c.id == widget.counterId).firstOrNull;
    if (mounted) {
      setState(() {
        _counter = found;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final counter = _counter;
    if (counter == null) {
      return AppScaffold(
        title: '纪念日',
        showBack: true,
        body: const Center(child: Text('纪念日不存在')),
      );
    }
    return _buildContent(counter);
  }

  Widget _buildContent(DayCounter counter) {
    final hasImage = counter.image.isNotEmpty;
    return Scaffold(
      body: Stack(
        children: [
          // 背景图 / 渐变
          Positioned.fill(
            child: hasImage
                ? _BackgroundImage(stored: counter.image)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
          ),
          // 暗色蒙层（让文字清晰）
          if (hasImage)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

          // 内容
          SafeArea(
            child: Column(
              children: [
                // 顶部栏：返回 + 编辑
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: hasImage ? Colors.white : null,
                      onPressed: () => context.pop(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: hasImage ? Colors.white : null,
                      onPressed: () async {
                        await context.push(
                          '/day-counter/edit/${counter.id}',
                        );
                        // 返回时刷新
                        if (mounted) _load();
                      },
                    ),
                  ],
                ),

                // 主内容：倒计时
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 标题
                        Text(
                          counter.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: hasImage
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            shadows: hasImage
                                ? const [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 表情 + 日期
                        Text(
                          '${counter.emoji} ${counter.displayDate}',
                          style: TextStyle(
                            fontSize: 16,
                            color: hasImage
                                ? Colors.white70
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            shadows: hasImage
                                ? const [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 48),
                        // 大字倒计时
                        _CountdownDisplay(counter: counter, hasImage: hasImage),
                      ],
                    ),
                  ),
                ),

                // 底部：目标日期
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    _targetDateText(counter),
                    style: TextStyle(
                      fontSize: 14,
                      color: hasImage
                          ? Colors.white70
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _targetDateText(DayCounter c) {
    if (c.counterType == CounterType.birthday) {
      return '每年 ${c.targetDate}';
    }
    try {
      final d = DateTime.parse(c.targetDate);
      return DateFormat('yyyy 年 M 月 d 日 EEEE', 'zh_CN').format(d);
    } catch (_) {
      return c.targetDate;
    }
  }
}

class _CountdownDisplay extends StatelessWidget {
  final DayCounter counter;
  final bool hasImage;
  const _CountdownDisplay({required this.counter, required this.hasImage});

  @override
  Widget build(BuildContext context) {
    final days = counter.daysUntil;
    final label = counter.labelText;
    final color = hasImage ? Colors.white : Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // 大数字
        Text(
          '$days',
          style: TextStyle(
            fontSize: 120,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1.0,
            shadows: hasImage
                ? const [
                    Shadow(color: Colors.black54, blurRadius: 8),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          days == 0 ? '天' : '天 $label',
          style: TextStyle(
            fontSize: 24,
            color: hasImage
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// 背景图渲染 — 支持 base64 (Web) 和 Native 路径
class _BackgroundImage extends StatelessWidget {
  final String stored;
  const _BackgroundImage({required this.stored});

  @override
  Widget build(BuildContext context) {
    if (stored.startsWith('data:')) {
      try {
        final base64Str = stored.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black26),
        );
      } catch (_) {
        return const ColoredBox(color: Colors.black26);
      }
    }
    // Native 路径
    return FutureBuilder<dynamic>(
      future: ImageService.resolveImageAsync(stored),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || snapshot.data == null) {
          return const ColoredBox(color: Colors.black26);
        }
        return Image.file(
          snapshot.data as File,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black26),
        );
      },
    );
  }
}
