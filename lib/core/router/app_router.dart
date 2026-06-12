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
import '../theme/app_motion.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        // 底部 Tab 切换：NoTransitionPage（无动画，秒切）
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
    // 详情页：自定义 fade+slide 过渡（300ms）
    GoRoute(
      path: '/search',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SearchPage(),
        transitionDuration: AppMotion.normal,
        reverseTransitionDuration: AppMotion.quick,
        transitionsBuilder: buildRouteTransition,
      ),
    ),
    GoRoute(
      path: '/stats',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const StatsPage(),
        transitionDuration: AppMotion.normal,
        reverseTransitionDuration: AppMotion.quick,
        transitionsBuilder: buildRouteTransition,
      ),
    ),
    GoRoute(
      path: '/diary/edit',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: DiaryEditPage(extra: state.extra),
        transitionDuration: AppMotion.normal,
        reverseTransitionDuration: AppMotion.quick,
        transitionsBuilder: buildRouteTransition,
      ),
    ),
    GoRoute(
      path: '/day-counter/add',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: DayCounterAddPage(counter: state.extra as DayCounter?),
        transitionDuration: AppMotion.normal,
        reverseTransitionDuration: AppMotion.quick,
        transitionsBuilder: buildRouteTransition,
      ),
    ),
    GoRoute(
      path: '/day-counter/view',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: DayCounterViewPage(counterId: state.extra as int),
        transitionDuration: AppMotion.normal,
        reverseTransitionDuration: AppMotion.quick,
        transitionsBuilder: buildRouteTransition,
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
