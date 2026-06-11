// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_counter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DayCounterImpl _$$DayCounterImplFromJson(Map<String, dynamic> json) =>
    _$DayCounterImpl(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      targetDate: json['targetDate'] as String,
      emoji: json['emoji'] as String? ?? '📅',
      colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 0,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$$DayCounterImplToJson(_$DayCounterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'targetDate': instance.targetDate,
      'emoji': instance.emoji,
      'colorIndex': instance.colorIndex,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt,
    };
