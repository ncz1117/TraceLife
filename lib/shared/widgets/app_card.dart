import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap != null || onLongPress != null) {
      return Card(
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}
