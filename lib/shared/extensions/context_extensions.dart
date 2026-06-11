import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  bool get isDarkMode => theme.brightness == Brightness.dark;
  AppColors get appColors => theme.extension<AppColors>()!;
  Size get screenSize => mediaQuery.size;
}
