import 'package:freezed_annotation/freezed_annotation.dart';

part 'diary.freezed.dart';
part 'diary.g.dart';

@freezed
class Diary with _$Diary {
  const factory Diary({
    int? id,
    required String date,
    @Default('') String content,
    @Default(3) int mood,
    String? createdAt,
    String? updatedAt,
  }) = _Diary;

  factory Diary.fromJson(Map<String, dynamic> json) => _$DiaryFromJson(json);

  const Diary._();
}

extension DiaryDb on Diary {
  Map<String, dynamic> toDb() => {
        if (id != null) 'id': id,
        'date': date,
        'content': content,
        'mood': mood,
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

  Diary withUpdatedNow() => copyWith(
        updatedAt: DateTime.now().toIso8601String(),
      );
}

extension DiaryMapper on Diary {
  static Diary fromDb(Map<String, dynamic> map) => Diary(
        id: map['id'] as int?,
        date: map['date'] as String,
        content: map['content'] as String? ?? '',
        mood: map['mood'] as int? ?? 3,
        createdAt: map['created_at'] as String?,
        updatedAt: map['updated_at'] as String?,
      );
}
