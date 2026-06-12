import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:convert' show base64Decode;
import 'dart:io' show File;
import 'model/day_counter.dart';
import 'providers/day_counter_providers.dart';
import '../../core/services/image_service.dart';
import '../../shared/extensions/context_extensions.dart';

/// 纪念日查看页（封面图风格 — Days Matter 范本）
/// 信息层级：顶部标题 / 中央大数字 / 底部起始日
///
/// 颜色策略：
/// - 有图：文字白色（on-image），蒙层走 appColors.scrim
/// - 无图：文字主题色，渐变从 primaryContainer → primary（同色系，避 AI 通用渐变痕）
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
    final days = counter.daysUntil;
    final label = counter.labelText;
    final scrim = context.appColors.scrim;

    return Scaffold(
      body: Stack(
        children: [
          // 背景层
          Positioned.fill(
            child: hasImage
                ? _BackgroundImage(stored: counter.image)
                : Container(
                    // 同色系渐变：primaryContainer → primary
                    // 比 primaryContainer → surface 更克制，避免 AI 通用渐变痕
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.primary,
                        ],
                      ),
                    ),
                  ),
          ),

          // 蒙层（让文字始终清晰）— 走 appColors.scrim
          if (hasImage)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scrim.withValues(alpha: 0.45),
                      scrim.withValues(alpha: 0.25),
                      scrim.withValues(alpha: 0.65),
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
                        // 编辑：用 /day-counter/add 路由 + extra 传 counter
                        // （路由 schema：null = 新建，非空 = 编辑）
                        await context.push(
                          '/day-counter/add',
                          extra: counter,
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
                                style: context.textStyles.memorialTitle
                                    .copyWith(
                                  color: hasImage
                                      ? _onImageColor
                                      : Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // 日期副标
                        Text(
                          counter.displayDate,
                          style: context.textStyles.memorialSubtitle
                              .copyWith(
                            color: hasImage
                                ? _onImageMuted
                                : Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withValues(alpha: 0.7),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 2. 中央：大数字（衬线体）
                        Semantics(
                          value: '$days$label',
                          child: _BigNumber(
                            days: days,
                            label: label,
                            hasImage: hasImage,
                          ),
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

// 有图时的文字颜色（始终白）
const Color _onImageColor = Colors.white;
const Color _onImageMuted = Colors.white70;
const Color _onImageSubtle = Color(0xD9FFFFFF); // white with alpha 0.85

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
    // 有图：白字；无图：主色（与背景 primary 拉开层次用 onPrimary）
    final color = hasImage
        ? _onImageColor
        : Theme.of(context).colorScheme.onPrimary;

    return Column(
      children: [
        // 大数字
        Text(
          '$days',
          style: context.textStyles.heroNumber.copyWith(
            color: color,
            shadows: hasImage
                ? [
                    // scrim-based shadow，替代 Colors.black54
                    Shadow(
                      color: context.appColors.scrim.withValues(alpha: 0.54),
                      blurRadius: 12,
                    ),
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
              style: context.textStyles.memorialDay.copyWith(
                color: hasImage
                    ? _onImageColor
                    : Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: hasImage
                    ? _onImageColor.withValues(alpha: 0.2)
                    : Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                days == 0 ? '今天' : label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: hasImage
                      ? _onImageColor
                      : Theme.of(context).colorScheme.onPrimary,
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
        ? _onImageSubtle
        : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.85);

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
          style: context.textStyles.memorialFooterLabel.copyWith(
            color: color.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          dateText,
          style: context.textStyles.memorialFooterDate.copyWith(color: color),
        ),
      ],
    );
  }
}

/// 圆形图标按钮（用 scrim 当背景，替代 Colors.black.withValues(alpha: 0.35)）
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Material(
        color: context.appColors.scrim.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: _onImageColor, size: 22),
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
    // 加载中/失败时的兜底色：scrim 低 alpha
    final fallback = ColoredBox(
      color: context.appColors.scrim.withValues(alpha: 0.15),
    );

    if (stored.startsWith('data:')) {
      try {
        final base64Str = stored.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        );
      } catch (_) {
        return fallback;
      }
    }
    return FutureBuilder<dynamic>(
      future: ImageService.resolveImageAsync(stored),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == null) {
          return fallback;
        }
        return Image.file(
          snapshot.data as File,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        );
      },
    );
  }
}
