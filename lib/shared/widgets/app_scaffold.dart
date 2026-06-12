import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_layout.dart';
import '../../core/theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool showBack;
  final Future<bool> Function()? onWillPop;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.showBack = false,
    this.onWillPop,
  });

  Future<void> _handleBack(BuildContext context) async {
    if (onWillPop != null) {
      final shouldPop = await onWillPop!();
      if (!shouldPop) return;
    }
    if (context.mounted) {
      GoRouter.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: onWillPop == null,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack(context);
      },
      child: Scaffold(
        appBar: title != null || showBack
            ? AppBar(
                title: title != null ? Text(title!) : null,
                actions: actions,
                leading: showBack
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => _handleBack(context),
                      )
                    : null,
              )
            : null,
        // body: SafeArea > LayoutBuilder > Center+ConstrainedBox(contentMaxWidth) > Padding > body
        // 宽屏（>= 840）自动居中 + 限宽 720
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppLayout.contentMaxWidth(constraints.maxWidth),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: body,
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
