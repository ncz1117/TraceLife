import 'package:flutter/material.dart';

/// 动效时长 token（100/300/500 规则）
///
/// 100/150ms — 即时反馈（按键、toggle、变色）
/// 200/300ms — 状态变化（菜单、tooltip、hover）
/// 300/500ms — 布局变化（手风琴、modal、drawer）
/// 500/800ms — 入场（页面加载、hero）
///
/// 同时遵守 `prefers-reduced-motion`：用户系统设置减弱动画时，
/// Flutter 自动传递 `MediaQuery.disableAnimations = true`，
/// 所有动画时长退化为 0。
class AppMotion {
  const AppMotion._();

  // 时长档位
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration emphasized = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);

  // ────────────── Easing（不用 CSS 默认）──────────────
  /// ease-out-quart: 平滑（默认）
  static const Curve easeOutQuart = Cubic(0.25, 1, 0.5, 1);
  /// ease-out-quint: 略快
  static const Curve easeOutQuint = Cubic(0.22, 1, 0.36, 1);
  /// ease-out-expo: 自信果断（modal/drawer 入场）
  static const Curve easeOutExpo = Cubic(0.16, 1, 0.3, 1);

  // ────────────── 距离/位移 token ───────────────
  /// 列表 stagger：每项 50ms（10 项 × 50ms = 500ms 上限）
  static const Duration stagger = Duration(milliseconds: 50);
  /// 卡片 hover：scale 1.02-1.05
  static const double hoverScale = 1.02;
  /// 按钮 click：scale 0.95
  static const double pressScale = 0.95;

  // ────────────── Reduced Motion 检查 ───────────────

  /// 当前上下文是否减弱动画
  /// 用法：`AppMotion.shouldAnimate(context)`
  static bool shouldAnimate(BuildContext context) {
    return !MediaQuery.of(context).disableAnimations;
  }

  /// 根据 reduced motion 返回实际时长
  /// reduced = 0ms（瞬时），否则用给定值
  static Duration duration(BuildContext context, Duration defaultDuration) {
    if (!shouldAnimate(context)) return Duration.zero;
    return defaultDuration;
  }

  /// 根据 reduced motion 返回 actual curve
  /// reduced = linear（无动画），否则用给定 curve
  static Curve curve(BuildContext context, Curve defaultCurve) {
    if (!shouldAnimate(context)) return Curves.linear;
    return defaultCurve;
  }
}

/// 全局 AnimatedContainer wrapper：自动遵守 reduced motion
class MotionContainer extends StatelessWidget {
  final Duration duration;
  final Curve curve;
  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Widget? child;

  const MotionContainer({
    super.key,
    this.duration = AppMotion.normal,
    this.curve = AppMotion.easeOutQuart,
    this.decoration,
    this.padding,
    this.width,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.duration(context, duration),
      curve: AppMotion.curve(context, curve),
      decoration: decoration,
      padding: padding,
      width: width,
      height: height,
      child: child,
    );
  }
}
