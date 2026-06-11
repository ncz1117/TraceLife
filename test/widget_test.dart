import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_life/features/today/today_page.dart';
import 'package:trace_life/features/day_counter/day_counter_page.dart';
import 'package:trace_life/core/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light(),
      home: child,
    ),
  );
}

void main() {
  testWidgets('TodayPage renders without crash', (tester) async {
    await tester.pumpWidget(_wrap(const TodayPage()));
    await tester.pump();
    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets('DayCounterPage renders without crash', (tester) async {
    await tester.pumpWidget(_wrap(const DayCounterPage()));
    await tester.pump();
    expect(find.byType(DayCounterPage), findsOneWidget);
  });
}
