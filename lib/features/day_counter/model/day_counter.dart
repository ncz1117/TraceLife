import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_counter.freezed.dart';
part 'day_counter.g.dart';

/// 类型枚举
/// 0 = 普通纪念日 (从指定日期开始算)
/// 1 = 生日 (只选月日，计算到下一次的天数)
class CounterType {
  static const int countdown = 0;
  static const int birthday = 1;
}

@freezed
class DayCounter with _$DayCounter {
  const factory DayCounter({
    int? id,
    required String title,
    required String targetDate, // countdown: yyyy-MM-dd, birthday: MM-dd
    @Default(0) int counterType, // 0=countdown, 1=birthday
    @Default('📅') String emoji,
    @Default(0) int colorIndex,
    @Default(0) int sortOrder,
    String? createdAt,
  }) = _DayCounter;

  factory DayCounter.fromJson(Map<String, dynamic> json) =>
      _$DayCounterFromJson(json);

  factory DayCounter.fromDb(Map<String, dynamic> map) => DayCounter(
        id: map['id'] as int?,
        title: map['title'] as String,
        targetDate: map['target_date'] as String,
        counterType: map['counter_type'] as int? ?? 0,
        emoji: map['emoji'] as String? ?? '📅',
        colorIndex: map['color_index'] as int? ?? 0,
        sortOrder: map['sort_order'] as int? ?? 0,
        createdAt: map['created_at'] as String?,
      );

  Map<String, dynamic> toDb() => {
        if (id != null) 'id': id,
        'title': title,
        'target_date': targetDate,
        'counter_type': counterType,
        'emoji': emoji,
        'color_index': colorIndex,
        'sort_order': sortOrder,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
      };

  const DayCounter._();
}

extension DayCounterX on DayCounter {
  /// 已过天数（普通纪念日）
  int get daysPassed {
    final target = DateTime.parse(_fullDate);
    return DateTime.now().difference(target).inDays;
  }

  bool get isFuture => daysPassed < 0;

  /// 到下一次的天数
  int get daysUntil {
    if (counterType == CounterType.birthday) {
      return _birthdayDaysRemaining;
    }
    // 普通纪念日：未来日期显示剩余，已过显示已过
    final d = daysPassed;
    return d < 0 ? -d : d; // 负数转正（剩余天数）
  }

  /// 显示文案："已过 / 剩余 / 还有"
  String get labelText {
    if (counterType == CounterType.birthday) {
      return _birthdayDaysRemaining == 0 ? '今天' : '还有';
    }
    if (isFuture) return '剩余';
    if (daysPassed == 0) return '今天';
    return '已过';
  }

  /// 用于日期显示的完整日期
  String get _fullDate {
    if (counterType == CounterType.birthday) {
      // 生日模式：用今年或明年来补全年份
      final now = DateTime.now();
      final parts = targetDate.split('-');
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      final thisYear = DateTime(now.year, month, day);
      if (thisYear.isBefore(now.subtract(const Duration(days: 1)))) {
        return '${now.year + 1}-$targetDate';
      }
      return '${now.year}-$targetDate';
    }
    return targetDate;
  }

  /// 生日模式剩余天数
  int get _birthdayDaysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final parts = targetDate.split('-');
    final month = int.parse(parts[0]);
    final day = int.parse(parts[1]);
    var next = DateTime(now.year, month, day);
    if (next.isBefore(today)) {
      next = DateTime(now.year + 1, month, day);
    }
    return next.difference(today).inDays;
  }

  /// 用于展示的日期字符串
  String get displayDate {
    if (counterType == CounterType.birthday) {
      return targetDate; // MM-dd
    }
    final parts = targetDate.split('-');
    return '${parts[0]}年${parts[1]}月${parts[2]}日';
  }
}
