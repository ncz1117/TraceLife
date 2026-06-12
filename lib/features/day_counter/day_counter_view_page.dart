import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert' show base64Decode;
import 'dart:io' show File;
import 'model/day_counter.dart';
import 'providers/day_counter_providers.dart';
import '../../core/services/image_service.dart';

/// 纪念日查看页（封面图风格 — Days Matter 范本）
/// 信息层级：顶部标题 / 中央大数字 / 底部起始日
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final counter = _counter;
    if (counter == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('纪念日不存在')),
      );
    }
    return _buildContent(counter);
  }

  Widget _buildContent(DayCounter counter) {
    final hasImage = counter.image.isNotEmpty;
    final isFuture = counter.isFuture;
    final days = counter.daysUntil;
    final label = counter.labelText;

    return Scaffold(
      body: Stack(
        children: [
          // 背景层
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

          // 蒙层（让文字始终清晰）
          if (hasImage)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.65),
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
                // 顶部栏
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => context.pop(),
                    ),
                    _CircleIconButton(
                      icon: Icons.edit_outlined,
                      onPressed: () async {
                        await context.push(
                          '/day-counter/edit/${counter.id}',
                        );
                        if (mounted) _load();
                      },
                    ),
                  ],
                ),

                // 主内容（3 段布局）
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. 顶部：标题 + emoji
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              counter.emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                counter.title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.notoSerifSc(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: hasImage
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // 日期副标
                        Text(
                          counter.displayDate,
                          style: GoogleFonts.notoSansSc(
                            fontSize: 13,
                            color: hasImage
                                ? Colors.white70
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 2. 中央：大数字（衬线体）
                        _BigNumber(
                          days: days,
                          label: label,
                          hasImage: hasImage,
                        ),

                        const SizedBox(height: 32),

                        // 3. 底部：起始日 / 目标日 / 生日提示
                        _FooterDate(counter: counter, hasImage: hasImage),
                      ],
                    ),
                  ),
                ),

                // 底部呼吸空间
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 大数字（衬线体 + 适当字号）
class _BigNumber extends StatelessWidget {
  final int days;
  final String label;
  final bool hasImage;
  const _BigNumber({
    required this.days,
    required this.label,
    required this.hasImage,
  });

  @override
  Widget build(BuildContext context) {
    final color = hasImage ? Colors.white : Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // 大数字
        Text(
          '$days',
          style: GoogleFonts.playfairDisplay(
            fontSize: 100, // 100sp（之前 120sp 太大）
            fontWeight: FontWeight.w900,
            color: color,
            height: 1.0,
            shadows: hasImage
                ? const [
                    Shadow(color: Colors.black54, blurRadius: 12),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        // 「天」+ 状态标签
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '天',
              style: GoogleFonts.notoSerifSc(
                fontSize: 20,
                color: hasImage
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: hasImage
                    ? Colors.white.withValues(alpha: 0.2)
                    : Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                days == 0 ? '今天' : label,
                style: GoogleFonts.notoSansSc(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: hasImage
                      ? Colors.white
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 底部：起始日 / 目标日
class _FooterDate extends StatelessWidget {
  final DayCounter counter;
  final bool hasImage;
  const _FooterDate({required this.counter, required this.hasImage});

  @override
  Widget build(BuildContext context) {
    final isFuture = counter.isFuture;
    final isBirthday = counter.counterType == CounterType.birthday;
    final color = hasImage
        ? Colors.white.withValues(alpha: 0.85)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    String dateText;
    String caption;

    if (isBirthday) {
      dateText = '每年 ${counter.targetDate}';
      caption = '生日';
    } else if (isFuture) {
      // 未来：目标日
      try {
        final d = DateTime.parse(counter.targetDate);
        dateText = DateFormat('yyyy 年 M 月 d 日', 'zh_CN').format(d);
        caption = '目标日';
      } catch (_) {
        dateText = counter.targetDate;
        caption = '目标日';
      }
    } else {
      // 已过：起始日
      try {
        final d = DateTime.parse(counter.targetDate);
        dateText = DateFormat('yyyy 年 M 月 d 日', 'zh_CN').format(d);
        caption = '起始日';
      } catch (_) {
        dateText = counter.targetDate;
        caption = '起始日';
      }
    }

    return Column(
      children: [
        Text(
          caption,
          style: GoogleFonts.notoSansSc(
            fontSize: 11,
            color: color.withValues(alpha: 0.7),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          dateText,
          style: GoogleFonts.notoSerifSc(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 圆形图标按钮
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
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
    return FutureBuilder<dynamic>(
      future: ImageService.resolveImageAsync(stored),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == null) {
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
