import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_counter.freezed.dart';
part 'day_counter.g.dart';

@freezed
class DayCounter with _$DayCounter {
  const factory DayCounter({
    int? id,
    required String title,
    required String targetDate,
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
        emoji: map['emoji'] as String? ?? '📅',
        colorIndex: map['color_index'] as int? ?? 0,
        sortOrder: map['sort_order'] as int? ?? 0,
        createdAt: map['created_at'] as String?,
      );

  Map<String, dynamic> toDb() => {
        if (id != null) 'id': id,
        'title': title,
        'target_date': targetDate,
        'emoji': emoji,
        'color_index': colorIndex,
        'sort_order': sortOrder,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
      };

  const DayCounter._();
}

extension DayCounterX on DayCounter {
  int get daysPassed {
    final target = DateTime.parse(targetDate);
    return DateTime.now().difference(target).inDays;
  }

  bool get isFuture => daysPassed < 0;
}
