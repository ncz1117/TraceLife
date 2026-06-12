import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.light,
    );
    return _baseTheme(colorScheme).copyWith(
      extensions: [AppColors.light],
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.dark,
    );
    return _baseTheme(colorScheme).copyWith(
      extensions: [AppColors.dark],
    );
  }

  static ThemeData _baseTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // ──────────── TextTheme：完整覆盖 ───────────
      // 所有 role 都用 token，方便 page 直接用 Theme.of(context).textTheme.X
      textTheme: _buildTextTheme(colorScheme),
      // ──────────── 圆角 token ───────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// 构建完整 TextTheme
  /// 所有 role 用 token（字号/字重/行高/字距），颜色由 usage 站点提供
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    // Body 颜色：onSurface
    // Display 颜色：onSurface（对比强）
    return TextTheme(
      // ─────── Display: 最大（页面 hero 文字） ───────
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: AppTypography.display,
        fontWeight: AppTypography.wBold,
        height: AppTypography.lhSnug,
        letterSpacing: AppTypography.lsTight,
        color: colorScheme.onSurface,
      ),
      displayMedium: AppTypography.serif(
        size: AppTypography.xxl,
        weight: AppTypography.wSemibold,
        height: AppTypography.lhSnug,
        letterSpacing: AppTypography.lsTight,
        color: colorScheme.onSurface,
      ),
      displaySmall: AppTypography.serif(
        size: AppTypography.xl,
        weight: AppTypography.wSemibold,
        height: AppTypography.lhSnug,
        color: colorScheme.onSurface,
      ),

      // ─────── Headline: 标题 ───────
      headlineLarge: AppTypography.serif(
        size: AppTypography.xl,
        weight: AppTypography.wSemibold,
        height: AppTypography.lhNormal,
        color: colorScheme.onSurface,
      ),
      headlineMedium: AppTypography.sans(
        size: AppTypography.lg,
        weight: AppTypography.wSemibold,
        height: AppTypography.lhNormal,
        color: colorScheme.onSurface,
      ),
      headlineSmall: AppTypography.sans(
        size: AppTypography.lg,
        weight: AppTypography.wSemibold,
        height: AppTypography.lhNormal,
        color: colorScheme.onSurface,
      ),

      // ─────── Title: 小标题/分组标题 ───────
      titleLarge: AppTypography.sans(
        size: AppTypography.bodyLg,
        weight: AppTypography.wSemibold,
        height: AppTypography.lhNormal,
        color: colorScheme.onSurface,
      ),
      titleMedium: AppTypography.sans(
        size: AppTypography.bodyLg,
        weight: AppTypography.wMedium,
        height: AppTypography.lhNormal,
        color: colorScheme.onSurface,
      ),
      titleSmall: AppTypography.sans(
        size: AppTypography.body,
        weight: AppTypography.wMedium,
        height: AppTypography.lhNormal,
        color: colorScheme.onSurface,
      ),

      // ─────── Body: 正文 ───────
      bodyLarge: AppTypography.sans(
        size: AppTypography.bodyLg,
        weight: AppTypography.wRegular,
        height: AppTypography.lhRelaxed,
        color: colorScheme.onSurface,
      ),
      bodyMedium: AppTypography.sans(
        size: AppTypography.body,
        weight: AppTypography.wRegular,
        height: AppTypography.lhRelaxed,
        color: colorScheme.onSurface,
      ),
      bodySmall: AppTypography.sans(
        size: AppTypography.sm,
        weight: AppTypography.wRegular,
        height: AppTypography.lhRelaxed,
        color: colorScheme.onSurfaceVariant,
      ),

      // ─────── Label: 按钮/标签 ───────
      labelLarge: AppTypography.sans(
        size: AppTypography.bodyLg,
        weight: AppTypography.wMedium,
        height: AppTypography.lhNormal,
        letterSpacing: AppTypography.lsOpen,
        color: colorScheme.onSurface,
      ),
      labelMedium: AppTypography.sans(
        size: AppTypography.body,
        weight: AppTypography.wMedium,
        height: AppTypography.lhNormal,
        color: colorScheme.onSurface,
      ),
      labelSmall: AppTypography.sans(
        size: AppTypography.sm,
        weight: AppTypography.wMedium,
        height: AppTypography.lhNormal,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
