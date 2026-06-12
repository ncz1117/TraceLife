import 'package:flutter/material.dart';

/// 应用颜色 token（语义化命名，不是值命名）
///
/// Restrained strategy: 中性 + 1 强调色 ≤ 10%
/// 避免 cream/sand 暖中性（AI 痕），用 OKLCH 思维定调
class AppColors extends ThemeExtension<AppColors> {
  // ── 心情色阶（5 档） ──
  final Color moodVerySad;
  final Color moodSad;
  final Color moodNeutral;
  final Color moodHappy;
  final Color moodVeryHappy;

  // ── 语义色（success/warning/info）──
  final Color success;
  final Color warning;
  final Color info;

  // ── 危险操作（删除/移除等）──
  final Color danger;

  // ── Scrim（蒙层，替代 Colors.black54 等硬编码）──
  // 始终是黑色（暗色模式用黑色加 alpha）
  // 浅色模式 alpha 更高，暗色模式 alpha 更低
  final Color scrim;

  const AppColors({
    required this.moodVerySad,
    required this.moodSad,
    required this.moodNeutral,
    required this.moodHappy,
    required this.moodVeryHappy,
    required this.success,
    required this.warning,
    required this.info,
    required this.danger,
    required this.scrim,
  });

  /// 浅色模式
  static const light = AppColors(
    // 心情：灰→蓝→米白→暖黄→橙红，OKLCH L 0.55-0.80
    moodVerySad: Color(0xFF6366F1),  // 蓝紫
    moodSad: Color(0xFF818CF8),      // 浅蓝紫
    moodNeutral: Color(0xFF9CA3AF),   // 灰
    moodHappy: Color(0xFFFBBF24),     // 暖黄
    moodVeryHappy: Color(0xFFF97316), // 橙红

    // 语义色（避免 Material 默认蓝，偏向有感情的色）
    success: Color(0xFF10B981),  // emerald
    warning: Color(0xFFF59E0B),  // amber
    info: Color(0xFF0EA5E9),     // sky（不用 Material default indigo）

    // 危险（不用 Material default red，偏向带一丝温度的）
    danger: Color(0xFFEF4444),  // red 500

    // 蒙层（浅色模式用 0.5 alpha 黑色）
    scrim: Color(0x80000000),
  );

  /// 暗色模式
  static const dark = AppColors(
    // 暗色下 chroma 略降，亮度提升
    moodVerySad: Color(0xFF818CF8),
    moodSad: Color(0xFFA5B4FC),
    moodNeutral: Color(0xFF6B7280),
    moodHappy: Color(0xFFFCD34D),
    moodVeryHappy: Color(0xFFFB923C),

    success: Color(0xFF34D399),  // emerald 400
    warning: Color(0xFFFBBF24),  // amber 400
    info: Color(0xFF38BDF8),     // sky 400

    danger: Color(0xFFF87171),   // red 400

    // 蒙层（暗色模式用 0.7 alpha 黑色，更深）
    scrim: Color(0xB3000000),
  );

  @override
  AppColors copyWith({
    Color? moodVerySad,
    Color? moodSad,
    Color? moodNeutral,
    Color? moodHappy,
    Color? moodVeryHappy,
    Color? success,
    Color? warning,
    Color? info,
    Color? danger,
    Color? scrim,
  }) {
    return AppColors(
      moodVerySad: moodVerySad ?? this.moodVerySad,
      moodSad: moodSad ?? this.moodSad,
      moodNeutral: moodNeutral ?? this.moodNeutral,
      moodHappy: moodHappy ?? this.moodHappy,
      moodVeryHappy: moodVeryHappy ?? this.moodVeryHappy,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      danger: danger ?? this.danger,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      moodVerySad: Color.lerp(moodVerySad, other.moodVerySad, t)!,
      moodSad: Color.lerp(moodSad, other.moodSad, t)!,
      moodNeutral: Color.lerp(moodNeutral, other.moodNeutral, t)!,
      moodHappy: Color.lerp(moodHappy, other.moodHappy, t)!,
      moodVeryHappy: Color.lerp(moodVeryHappy, other.moodVeryHappy, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}
