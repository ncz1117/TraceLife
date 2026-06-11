import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/today/today_page.dart';
import '../../features/diary/diary_page.dart';
import '../../features/day_counter/day_counter_page.dart';
import '../../features/diary/diary_edit_page.dart';
import '../../features/day_counter/day_counter_add_page.dart';
import '../../features/day_counter/model/day_counter.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TodayPage(),
          ),
        ),
        GoRoute(
          path: '/diary',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DiaryPage(),
          ),
        ),
        GoRoute(
          path: '/day-counter',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DayCounterPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/diary/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => DiaryEditPage(
        date: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/day-counter/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => DayCounterAddPage(
        counter: state.extra as DayCounter?,
      ),
    ),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/diary') && !location.startsWith('/diary/edit')) return 1;
    if (location.startsWith('/day-counter') && !location.startsWith('/day-counter/add')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/');
            case 1:
              context.go('/diary');
            case 2:
              context.go('/day-counter');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_rounded),
            selectedIcon: Icon(Icons.today_rounded),
            label: '今天',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book_rounded),
            label: '日记',
          ),
          NavigationDestination(
            icon: Icon(Icons.celebration_outlined),
            selectedIcon: Icon(Icons.celebration_rounded),
            label: '纪念日',
          ),
        ],
      ),
    );
  }
}
