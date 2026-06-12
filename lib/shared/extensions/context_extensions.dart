import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  bool get isDarkMode => theme.brightness == Brightness.dark;
  AppColors get appColors => theme.extension<AppColors>()!;
  Size get screenSize => mediaQuery.size;

  /// 扩展 textTheme — 包含非常规的 hero/title 字体
  CustomTextStyles get textStyles => const CustomTextStyles();
}

/// 自定义 text styles（超出标准 TextTheme role）
class CustomTextStyles {
  const CustomTextStyles();

  /// 纪念日大数字（Playfair Display 900）
  /// 用法：`context.textStyles.heroNumber.copyWith(color: ...)`
  TextStyle get heroNumber => AppTypography.hero(
        size: AppTypography.heroSize,
        weight: AppTypography.wBlack,
        height: AppTypography.lhTight,
      );

  /// 纪念日标题（衬线 + Semibold）
  /// 用法：`context.textStyles.memorialTitle.copyWith(color: ...)`
  TextStyle get memorialTitle => AppTypography.serif(
        size: AppTypography.xxl,
        weight: AppTypography.wSemibold,
        height: AppTypography.lhSnug,
        letterSpacing: AppTypography.lsOpen,
      );

  /// 纪念日副标（无衬线 + tracked）
  TextStyle get memorialSubtitle => AppTypography.sans(
        size: AppTypography.sm,
        weight: AppTypography.wMedium,
        height: AppTypography.lhNormal,
        letterSpacing: AppTypography.lsTracked,
      );

  /// 纪念日"天"字
  TextStyle get memorialDay => AppTypography.serif(
        size: AppTypography.lg,
        weight: AppTypography.wMedium,
        height: AppTypography.lhNormal,
      );

  /// 纪念日底部日期标签（小帽 + tracked）
  TextStyle get memorialFooterLabel => AppTypography.sans(
        size: AppTypography.xs,
        weight: AppTypography.wMedium,
        height: AppTypography.lhNormal,
        letterSpacing: AppTypography.lsCaps,
      );

  /// 纪念日底部日期（衬线 + Medium）
  TextStyle get memorialFooterDate => AppTypography.serif(
        size: AppTypography.body,
        weight: AppTypography.wMedium,
        height: AppTypography.lhNormal,
      );
}
