/// 布局 token
/// - 断点 (compact/medium/expanded/large)
/// - contentMaxWidth 宽屏最大宽度
/// - 半径 (xs/sm/md/lg/xl/full)
class AppLayout {
  const AppLayout._();

  // ===== 断点（px） =====
  // 移动端竖屏 | 移动端横屏/折叠 | 平板 | 桌面/Web
  static const double breakpointCompact = 0;
  static const double breakpointMedium = 600;
  static const double breakpointExpanded = 840;
  static const double breakpointLarge = 1200;

  // ===== 圆角（已对齐 AppSpacing.radiusXxx） =====
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // ===== 内容最大宽度（Web/宽屏下自动限宽 + 居中） =====
  static double contentMaxWidth(double availableWidth) {
    if (availableWidth >= breakpointLarge) return 960; // 大屏：960
    if (availableWidth >= breakpointExpanded) return 840; // 平板：840
    if (availableWidth >= breakpointMedium) return 600; // 小屏横屏：600
    return availableWidth; // compact：撑满
  }

  // ===== 断点判断 =====
  static bool isCompact(double w) => w < breakpointMedium;
  static bool isMedium(double w) => w >= breakpointMedium && w < breakpointExpanded;
  static bool isExpanded(double w) => w >= breakpointExpanded && w < breakpointLarge;
  static bool isLarge(double w) => w >= breakpointLarge;
}
