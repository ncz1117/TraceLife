import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/midnight_controller.dart';

/// 动效时长 token（100/300/500 规则）
///
/// 100/150ms - 即时反馈（按键、toggle、变色）
/// 200/300ms - 状态变化（菜单、tooltip、hover）
/// 300/500ms - 布局变化（手风琴、modal、drawer）
/// 500/800ms - 进入/退出（页面、卡片）
/// 1000ms+   - 环境（呼吸、心跳、加载）
class AppMotion {
  const AppMotion._();

  // 时长（毫秒）
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration ambient = Duration(seconds: 2);

  // 曲线
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve overshoot = Curves.easeOutBack;

  // 数值
  static const double microScale = 1.02;
  static const double smallScale = 1.05;
  static const double largeScale = 1.15;
}

/// 减少动画判断
bool _prefersReducedMotion(BuildContext context) {
  return MediaQuery.of(context).disableAnimations;
}

/// 动画控制器工厂（自动尊重 reduced-motion）
AnimationController createMotionController({
  required TickerProvider vsync,
  required Duration duration,
  Duration? reverseDuration,
}) {
  return AnimationController(
    duration: duration,
    reverseDuration: reverseDuration ?? duration,
    vsync: vsync,
  );
}

/// 翻页动效 widget
///
/// 用途：数字/状态在"跨日"时短暂"翻页"（淡出 + 缩小 → 淡入 + 放大）
/// 关键：用 [ValueKey] 让 Flutter 在 child 真正变化时才重新构建 + 触发动画
/// - 同值 → 同一个 widget，无动画
/// - 异值 → 新 widget，~600ms 翻页
class PageFlip extends StatelessWidget {
  final Object value; // 用作 key 触发差异检测
  final Widget child;
  final Duration duration;

  const PageFlip({
    super.key,
    required this.value,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(value),
        child: child,
      ),
    );
  }
}

/// 跨日提示 badge（"✨ 新的一天" 短暂出现 1.5s）
///
/// 监听 [midnightControllerProvider] 的 state 变化：
/// - state 变化时（午夜）→ 显 1.5s → 自动淡出
class MidnightBadge extends ConsumerStatefulWidget {
  /// 要监听的午夜信号 provider（默认全局午夜信号）
  final ProviderListenable<int> Function(WidgetRef ref)? provider;

  const MidnightBadge({super.key, this.provider});

  @override
  ConsumerState<MidnightBadge> createState() => _MidnightBadgeState();
}

class _MidnightBadgeState extends ConsumerState<MidnightBadge> {
  bool _visible = false;
  int _lastSeen = 0;

  @override
  Widget build(BuildContext context) {
    // 监听午夜信号：state 变化 → 显示 1.5s → 隐藏
    ref.listen(midnightControllerProvider, (prev, next) {
      if (next != _lastSeen && next > 0) {
        _lastSeen = next;
        setState(() => _visible = true);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) setState(() => _visible = false);
        });
      }
    });

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: _visible
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '新的一天',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

/// 通用缩放/透明度 Pulse widget
/// - 默认：对称呼吸（easeInOut, 1.0 ↔ maxScale）
/// - heartbeat: 非对称（30% 收缩 + 70% 舒张，模拟真实心率）
/// - reduced-motion 下直接返回 child 不动
class Pulse extends StatefulWidget {
  final Widget child;
  final double maxScale;
  final Duration period;
  final bool enabled;
  final bool heartbeat;

  const Pulse({
    super.key,
    required this.child,
    this.maxScale = 1.05,
    this.period = const Duration(milliseconds: 2400),
    this.enabled = true,
    this.heartbeat = false,
  });

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: widget.period,
      vsync: this,
    );
    _scale = widget.heartbeat
        ? TweenSequence<double>([
            // 收缩：1.0 → maxScale，30% 周期，easeOut（快入）
            TweenSequenceItem(
              tween: Tween(begin: 1.0, end: widget.maxScale)
                  .chain(CurveTween(curve: Curves.easeOut)),
              weight: 30,
            ),
            // 舒张：maxScale → 1.0，70% 周期，easeInOut（慢出）
            TweenSequenceItem(
              tween: Tween(begin: widget.maxScale, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeInOut)),
              weight: 70,
            ),
          ]).animate(_ctrl)
        : Tween<double>(begin: 1.0, end: widget.maxScale)
            .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.enabled && !_prefersReducedMotion(context)) {
      _ctrl.repeat();
    }
  }

  @override
  void didUpdateWidget(Pulse old) {
    super.didUpdateWidget(old);
    if (widget.enabled != old.enabled) {
      if (widget.enabled && !_prefersReducedMotion(context)) {
        _ctrl.repeat();
      } else {
        _ctrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_prefersReducedMotion(context)) return widget.child;
    return ScaleTransition(
      scale: _scale,
      child: widget.child,
    );
  }
}

/// 路由过场动画 - fade + slide from right
Widget buildRouteTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final reduceMotion = MediaQuery.of(context).disableAnimations;
  if (reduceMotion) return child;
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}
