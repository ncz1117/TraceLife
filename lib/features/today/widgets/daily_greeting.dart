import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/theme/app_spacing.dart';

class DailyGreeting extends StatefulWidget {
  const DailyGreeting({super.key});

  @override
  State<DailyGreeting> createState() => _DailyGreetingState();
}

class _DailyGreetingState extends State<DailyGreeting> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = _now.hour;
    final minute = _now.minute.toString().padLeft(2, '0');
    final second = _now.second.toString().padLeft(2, '0');
    final greeting = hour < 12
        ? '早上好'
        : hour < 18
            ? '下午好'
            : '晚上好';
    final dateStr = '${_now.year}年${_now.month}月${_now.day}日';
    final weekday = AppDateUtils.formatWeekday(_now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$hour:$minute:$second',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w200,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$dateStr $weekday',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
