import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../features/day_counter/model/day_counter.dart';

/// 本地推送服务
/// - Native: flutter_local_notifications + timezone
/// - Web: 不支持，no-op（页面会显示提示）
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool get _isSupported => !kIsWeb;

  /// 初始化（app 启动时调用）
  static Future<void> init() async {
    if (!_isSupported) return;
    if (_isInitialized) return;

    // 加载时区数据
    tz_data.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      // Fallback: 用 UTC
      debugPrint('设置本地时区失败: $e');
    }

    // 初始化插件
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(initSettings);

    _isInitialized = true;
  }

  /// 请求通知权限
  /// 返回是否授权
  static Future<bool> requestPermissions() async {
    if (!_isSupported) return false;

    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  /// 检查权限状态
  static Future<bool> hasPermission() async {
    if (!_isSupported) return false;

    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return (result as bool?) ?? false;
    }
    if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return (result as bool?) ?? false;
    }
    return false;
  }

  /// 调度纪念日提醒
  /// [daysBefore] 提前几天（1/3/7）
  /// [hour] 几点提醒（0-23）
  static Future<void> scheduleCounterNotification({
    required DayCounter counter,
    int daysBefore = 1,
    int hour = 9,
  }) async {
    if (!_isSupported || !_isInitialized) return;
    if (counter.id == null) return;

    // 先取消旧的
    await cancelCounterNotification(counter.id!);

    // 纪念日类型：单次提醒
    if (counter.counterType == CounterType.countdown) {
      await _scheduleCountdown(counter, daysBefore, hour);
    } else {
      // 生日：每年提醒
      await _scheduleBirthday(counter, daysBefore, hour);
    }
  }

  static Future<void> _scheduleCountdown(
      DayCounter counter, int daysBefore, int hour) async {
    try {
      final target = DateTime.parse(counter.targetDate);
      // 在目标日期前 N 天提醒
      final triggerDate = DateTime(
        target.year,
        target.month,
        target.day,
        hour,
        0,
      ).subtract(Duration(days: daysBefore));
      final scheduledDate = tz.TZDateTime.from(triggerDate, tz.local);

      // 如果已过，不再调度
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        return;
      }

      await _plugin.zonedSchedule(
        counter.id!,
        '${counter.emoji} ${counter.title}',
        _buildBody(counter, daysBefore),
        scheduledDate,
        _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('已调度: ${counter.title} @ $scheduledDate');
    } catch (e) {
      debugPrint('调度失败: $e');
    }
  }

  static Future<void> _scheduleBirthday(
      DayCounter counter, int daysBefore, int hour) async {
    try {
      // 解析 MM-dd
      final parts = counter.targetDate.split('-');
      if (parts.length != 2) return;
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);

      // 用 matchDateTime 实现每年提醒
      final now = tz.TZDateTime.now(tz.local);
      var triggerDate = tz.TZDateTime(
        tz.local,
        now.year,
        month,
        day,
        hour,
        0,
      ).subtract(Duration(days: daysBefore));

      if (triggerDate.isBefore(now)) {
        triggerDate = tz.TZDateTime(
          tz.local,
          now.year + 1,
          month,
          day,
          hour,
          0,
        ).subtract(Duration(days: daysBefore));
      }

      await _plugin.zonedSchedule(
        counter.id!,
        '${counter.emoji} ${counter.title}',
        _buildBody(counter, daysBefore),
        triggerDate,
        _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('已调度（每年）: ${counter.title} @ $triggerDate');
    } catch (e) {
      debugPrint('生日调度失败: $e');
    }
  }

  static String _buildBody(DayCounter counter, int daysBefore) {
    final days = counter.daysUntil;
    if (counter.counterType == CounterType.birthday) {
      return '还有 $days 天';
    }
    if (counter.isFuture) {
      return '还有 $days 天';
    }
    return '已过 $days 天';
  }

  static NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'day_counter',
        '纪念日提醒',
        channelDescription: '纪念日、生日等重要日期提醒',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  /// 取消某个纪念日的提醒
  static Future<void> cancelCounterNotification(int id) async {
    if (!_isSupported) return;
    await _plugin.cancel(id);
  }

  /// 取消所有
  static Future<void> cancelAll() async {
    if (!_isSupported) return;
    await _plugin.cancelAll();
  }

  /// 重新调度所有纪念日（设置变更时调用）
  static Future<void> rescheduleAll(
    List<DayCounter> counters, {
    int daysBefore = 1,
    int hour = 9,
  }) async {
    if (!_isSupported) return;
    await cancelAll();
    for (final c in counters) {
      await scheduleCounterNotification(
        counter: c,
        daysBefore: daysBefore,
        hour: hour,
      );
    }
  }
}
