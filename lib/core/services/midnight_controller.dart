import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全局午夜信号器
///
/// 职责：每 30 秒检查一次系统日期，跨过午夜时 state++。
/// 任何想"跨日刷新"的 widget 只需：
///   ref.listen(midnightControllerProvider, (_, __) {
///     ref.invalidate(myDataProvider);
///   });
///
/// 设计取舍：
/// - 用 30s 轮询而非精确闹钟（耗电 + 后台不可靠）
/// - 切后台时依赖 AppLifecycleState.resumed 时再校准（main.dart 处理）
/// - state 从 0 开始递增，每次午夜 +1，不重复
class MidnightController extends Notifier<int> {
  Timer? _timer;
  late DateTime _knownDate;

  @override
  int build() {
    _knownDate = _currentDate();
    _timer = Timer.periodic(const Duration(seconds: 30), _check);
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    return 0;
  }

  /// 手动触发一次检查（用于 App 切回前台）
  void poke() {
    _check(null);
  }

  /// 强制触发一次翻页（仅用于测试：DevTools / 长按隐藏手势）
  /// 真实生产环境不会调用此方法
  void forceMidnight() {
    state = state + 1;
  }

  void _check(Timer? _) {
    final now = _currentDate();
    if (now != _knownDate) {
      _knownDate = now;
      state = state + 1;
    }
  }

  DateTime _currentDate() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}

final midnightControllerProvider =
    NotifierProvider<MidnightController, int>(MidnightController.new);
