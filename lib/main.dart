import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/l10n/app_localizations.dart';
import 'core/database/database_helper.dart';
import 'core/services/notification_service.dart';
import 'core/services/theme_controller.dart';
import 'core/services/midnight_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.init();
  await NotificationService.init();

  // 预加载主题（消除启动闪烁：默认主题 → 用户主题）
  final container = ProviderContainer();
  await container.read(themeControllerProvider.notifier).initialize();
  // 启动午夜信号器（每 30s 检查日期变化，跨午夜触发 state++）
  container.read(midnightControllerProvider);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(UncontrolledProviderScope(
    container: container,
    child: const TraceLifeApp(),
  ));
}

class TraceLifeApp extends ConsumerStatefulWidget {
  const TraceLifeApp({super.key});

  @override
  ConsumerState<TraceLifeApp> createState() => _TraceLifeAppState();
}

class _TraceLifeAppState extends ConsumerState<TraceLifeApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 切回前台时校准一次（后台可能跨日）
    if (state == AppLifecycleState.resumed) {
      ref.read(midnightControllerProvider.notifier).poke();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(themeControllerProvider);
    return MaterialApp.router(
      title: '迹录',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(preset: settings.preset, brightness: Brightness.light),
      darkTheme: AppTheme.build(preset: settings.preset, brightness: Brightness.dark),
      themeMode: settings.mode,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
