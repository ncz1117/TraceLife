import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 字体排版 token
///
/// 决策（已确认）：
/// - Register: product（app UI）
/// - 字号策略：固定 rem（不用 fluid clamp）
/// - Ratio: 1.2（major second）
/// - Body: Noto Sans SC（无衬线，所有 UI 文本）
/// - Title: Noto Serif SC（衬线，标题/数字 — 营造温暖/怀旧感）
/// - Hero: Playfair Display（衬线，仅纪念日大数字用）
///
/// 5 大原则（来自 Impeccable typeset）：
/// - 5-7 个尺寸覆盖 95% 场景
/// - body ≥ 16px（WCAG，移动端）
/// - heading 1.1-1.2，body 1.5-1.7
/// - 行长 max-width: 65ch
/// - 字重 3-4 档
class AppTypography {
  const AppTypography._();

  // ────────────── 字号 scale（1.2 ratio，9 档）──────────────
  // 不可用 < 11px，可读性下限
  static const double xs = 11; // 0.6875rem  — 图表标签/热力图数字
  static const double sm = 12; // 0.75rem    — caption, secondary
  static const double body = 14; // 0.875rem  — secondary body
  static const double bodyLg = 16; // 1.0rem   — default body ✅
  static const double lg = 19; // 1.1875rem   — subheading/button
  static const double xl = 23; // 1.4375rem   — heading
  static const double xxl = 28; // 1.75rem    — page title
  static const double display = 34; // 2.125rem — hero text (页面大标题)
  static const double heroSize = 100; // 6.25rem   — 纪念日大数字（独立 scale）

  // ────────────── 行高（line-height）──────────────
  static const double lhTight = 1.0; // hero, display
  static const double lhSnug = 1.1; // display, heading
  static const double lhNormal = 1.2; // heading, label
  static const double lhRelaxed = 1.5; // body
  static const double lhLoose = 1.7; // long-form body

  // ────────────── 字距（letter-spacing）──────────────
  static const double lsDefault = 0;
  static const double lsTight = -0.02; // display, hero
  static const double lsNormal = 0;
  static const double lsOpen = 0.5; // button
  static const double lsTracked = 1.2; // caption label
  static const double lsCaps = 2.0; // eyebrow / all-caps

  // ────────────── 字重（font-weight）──────────────
  // 限制 3 档，900 仅为 hero number
  static const FontWeight wRegular = FontWeight.w400; // body
  static const FontWeight wMedium = FontWeight.w500; // label, button
  static const FontWeight wSemibold = FontWeight.w600; // title
  static const FontWeight wBold = FontWeight.w700; // display
  static const FontWeight wBlack = FontWeight.w900; // hero number only

  // ────────────── 字体家族 helper ───────────────

  /// Body 字体：Noto Sans SC
  /// 用于：UI 文本、按钮、标签、正文、辅助文字、图表
  static TextStyle sans({
    double size = bodyLg,
    FontWeight weight = wRegular,
    double height = lhRelaxed,
    double letterSpacing = lsDefault,
    Color? color,
  }) {
    return GoogleFonts.notoSansSc(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// 衬线字体：Noto Serif SC
  /// 用于：标题、副标、日期（营造温暖/怀旧感）
  static TextStyle serif({
    double size = bodyLg,
    FontWeight weight = wRegular,
    double height = lhNormal,
    double letterSpacing = lsDefault,
    Color? color,
  }) {
    return GoogleFonts.notoSerifSc(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// Hero 字体：Playfair Display
  /// 仅用于：纪念日 ViewPage 的大数字（特殊时刻）
  static TextStyle hero({
    double size = heroSize,
    FontWeight weight = wBlack,
    double height = lhTight,
    double letterSpacing = lsTight,
    Color? color,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ────────────── 预设（semantic）──────────────

  /// 标签/小标题上的全大写
  static TextStyle eyebrow(Color color) => sans(
        size: xs,
        weight: wMedium,
        height: lhNormal,
        letterSpacing: lsCaps,
        color: color,
      );

  /// Button
  static TextStyle button(Color color) => sans(
        size: bodyLg,
        weight: wMedium,
        height: lhNormal,
        letterSpacing: lsOpen,
        color: color,
      );

  /// Page title (大)
  static TextStyle pageTitle(Color color) => serif(
        size: xxl,
        weight: wBold,
        height: lhSnug,
        letterSpacing: lsTight,
        color: color,
      );

  /// Section title (中)
  static TextStyle sectionTitle(Color color) => serif(
        size: xl,
        weight: wSemibold,
        height: lhSnug,
        letterSpacing: lsTight,
        color: color,
      );

  /// Section title (小) — 用 sans
  static TextStyle labelTitle(Color color) => sans(
        size: lg,
        weight: wSemibold,
        height: lhNormal,
        color: color,
      );
}
