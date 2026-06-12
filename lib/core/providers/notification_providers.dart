import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../../features/day_counter/providers/day_counter_providers.dart';

/// 推送设置状态
class NotificationSettings {
  final bool enabled; // 总开关
  final int daysBefore; // 提前几天（1/3/7）
  final int hour; // 几点提醒（0-23）

  const NotificationSettings({
    this.enabled = false,
    this.daysBefore = 1,
    this.hour = 9,
  });

  NotificationSettings copyWith({bool? enabled, int? daysBefore, int? hour}) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      daysBefore: daysBefore ?? this.daysBefore,
      hour: hour ?? this.hour,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final Ref _ref;
  NotificationSettingsNotifier(this._ref) : super(const NotificationSettings()) {
    _load();
  }

  static const _kEnabled = 'notif_enabled';
  static const _kDaysBefore = 'notif_days_before';
  static const _kHour = 'notif_hour';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationSettings(
      enabled: prefs.getBool(_kEnabled) ?? false,
      daysBefore: prefs.getInt(_kDaysBefore) ?? 1,
      hour: prefs.getInt(_kHour) ?? 9,
    );
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, value);
    state = state.copyWith(enabled: value);

    if (value) {
      if (!kIsWeb) {
        final granted = await NotificationService.requestPermissions();
        if (!granted) {
          state = state.copyWith(enabled: false);
          await prefs.setBool(_kEnabled, false);
          return;
        }
      }
      await _rescheduleAll();
    } else {
      await NotificationService.cancelAll();
    }
  }

  Future<void> setDaysBefore(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDaysBefore, days);
    state = state.copyWith(daysBefore: days);
    if (state.enabled) {
      await _rescheduleAll();
    }
  }

  Future<void> setHour(int hour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHour, hour);
    state = state.copyWith(hour: hour);
    if (state.enabled) {
      await _rescheduleAll();
    }
  }

  Future<void> _rescheduleAll() async {
    final counters = await _ref.read(dayCounterListProvider.future);
    await NotificationService.rescheduleAll(
      counters,
      daysBefore: state.daysBefore,
      hour: state.hour,
    );
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(ref),
);
