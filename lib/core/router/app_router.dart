import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/today/today_page.dart';
import '../../features/diary/diary_page.dart';
import '../../features/day_counter/day_counter_page.dart';
import '../../features/diary/diary_edit_page.dart';
import '../../features/day_counter/day_counter_add_page.dart';
import '../../features/day_counter/day_counter_view_page.dart';
import '../../features/day_counter/model/day_counter.dart';
import '../../features/settings/settings_page.dart';
import '../../features/search/search_page.dart';
import '../../features/stats/stats_page.dart';

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
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/stats',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const StatsPage(),
    ),
    GoRoute(
      path: '/diary/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => DiaryEditPage(
        extra: state.extra,
      ),
    ),
    GoRoute(
      path: '/day-counter/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => DayCounterAddPage(
        counter: state.extra as DayCounter?,
      ),
    ),
    GoRoute(
      path: '/day-counter/view',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => DayCounterViewPage(
        counterId: state.extra as int,
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
    if (location.startsWith('/day-counter') &&
        !location.startsWith('/day-counter/add') &&
        !location.startsWith('/day-counter/view')) return 2;
    if (location.startsWith('/settings')) return 3;
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
            case 3:
              context.go('/settings');
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
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
