/// 间距 token — 详细见 [AppLayout]
///
/// 8-base scale，2x 比例 + 1.5x 过渡档
/// 已对齐 app_layout.dart 的 spacingXxx 定义
class AppSpacing {
  const AppSpacing._();

  // 8-base scale
  static const double xxs = 2; // 极小负空间、边角
  static const double xs = 4;  // 紧贴：icon-text 间距
  static const double sm = 8;  // 元素内：padding inline
  static const double md = 12; // 1.5x 过渡：card 内部
  static const double lg = 16; // 标准：page 外 padding
  static const double xl = 24; // section 间
  static const double xxl = 32; // group 间
  static const double xxxl = 48; // page 上下
  static const double huge = 64; // hero spacing（极少用）

  // 半径（对齐 app_layout.dart 的 AppRadius）
  static const double radiusSm = 8;  // button/input
  static const double radiusMd = 12; // card
  static const double radiusLg = 16; // modal
  static const double radiusXl = 24; // hero
}
