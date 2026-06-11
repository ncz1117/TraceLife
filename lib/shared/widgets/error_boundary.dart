import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();

  static void showError(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null && messenger.mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('⚠️ $message'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: '知道了', onPressed: () {}),
        ),
      );
    }
  }
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  @override
  Widget build(BuildContext context) => widget.child;
}
