import 'package:flutter/material.dart';

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

/// 通用缩放/透明度 Pulse widget
/// - 静默时长（hold time）= duration 的 1 倍
/// - 缩放范围 1.0 -> 1.05 -> 1.0
/// - 慢节奏 0.4-0.5 Hz（避免焦虑感）
/// - reduced-motion 下直接返回 child 不动
class Pulse extends StatefulWidget {
  final Widget child;
  final double maxScale;
  final Duration period;
  final bool enabled;

  const Pulse({
    super.key,
    required this.child,
    this.maxScale = 1.05,
    this.period = const Duration(milliseconds: 2400),
    this.enabled = true,
  });

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: widget.period,
      vsync: this,
    );
    if (widget.enabled && !_prefersReducedMotion(context)) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(Pulse old) {
    super.didUpdateWidget(old);
    if (widget.enabled != old.enabled) {
      if (widget.enabled && !_prefersReducedMotion(context)) {
        _ctrl.repeat(reverse: true);
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
      scale: Tween<double>(begin: 1.0, end: widget.maxScale).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      ),
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
