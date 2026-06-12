// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiaryImpl _$$DiaryImplFromJson(Map<String, dynamic> json) => _$DiaryImpl(
  id: (json['id'] as num?)?.toInt(),
  date: json['date'] as String,
  content: json['content'] as String? ?? '',
  mood: (json['mood'] as num?)?.toInt() ?? 3,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$$DiaryImplToJson(_$DiaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'content': instance.content,
      'mood': instance.mood,
      'images': instance.images,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
