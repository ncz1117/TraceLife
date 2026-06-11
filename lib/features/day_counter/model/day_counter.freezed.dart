// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_counter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DayCounter _$DayCounterFromJson(Map<String, dynamic> json) {
  return _DayCounter.fromJson(json);
}

/// @nodoc
mixin _$DayCounter {
  int? get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get targetDate => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  int get colorIndex => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DayCounter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DayCounter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DayCounterCopyWith<DayCounter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayCounterCopyWith<$Res> {
  factory $DayCounterCopyWith(
    DayCounter value,
    $Res Function(DayCounter) then,
  ) = _$DayCounterCopyWithImpl<$Res, DayCounter>;
  @useResult
  $Res call({
    int? id,
    String title,
    String targetDate,
    String emoji,
    int colorIndex,
    int sortOrder,
    String? createdAt,
  });
}

/// @nodoc
class _$DayCounterCopyWithImpl<$Res, $Val extends DayCounter>
    implements $DayCounterCopyWith<$Res> {
  _$DayCounterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DayCounter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? targetDate = null,
    Object? emoji = null,
    Object? colorIndex = null,
    Object? sortOrder = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            targetDate: null == targetDate
                ? _value.targetDate
                : targetDate // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            colorIndex: null == colorIndex
                ? _value.colorIndex
                : colorIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DayCounterImplCopyWith<$Res>
    implements $DayCounterCopyWith<$Res> {
  factory _$$DayCounterImplCopyWith(
    _$DayCounterImpl value,
    $Res Function(_$DayCounterImpl) then,
  ) = __$$DayCounterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String title,
    String targetDate,
    String emoji,
    int colorIndex,
    int sortOrder,
    String? createdAt,
  });
}

/// @nodoc
class __$$DayCounterImplCopyWithImpl<$Res>
    extends _$DayCounterCopyWithImpl<$Res, _$DayCounterImpl>
    implements _$$DayCounterImplCopyWith<$Res> {
  __$$DayCounterImplCopyWithImpl(
    _$DayCounterImpl _value,
    $Res Function(_$DayCounterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DayCounter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? targetDate = null,
    Object? emoji = null,
    Object? colorIndex = null,
    Object? sortOrder = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$DayCounterImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        targetDate: null == targetDate
            ? _value.targetDate
            : targetDate // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        colorIndex: null == colorIndex
            ? _value.colorIndex
            : colorIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DayCounterImpl extends _DayCounter {
  const _$DayCounterImpl({
    this.id,
    required this.title,
    required this.targetDate,
    this.emoji = '📅',
    this.colorIndex = 0,
    this.sortOrder = 0,
    this.createdAt,
  }) : super._();

  factory _$DayCounterImpl.fromJson(Map<String, dynamic> json) =>
      _$$DayCounterImplFromJson(json);

  @override
  final int? id;
  @override
  final String title;
  @override
  final String targetDate;
  @override
  @JsonKey()
  final String emoji;
  @override
  @JsonKey()
  final int colorIndex;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'DayCounter(id: $id, title: $title, targetDate: $targetDate, emoji: $emoji, colorIndex: $colorIndex, sortOrder: $sortOrder, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayCounterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.targetDate, targetDate) ||
                other.targetDate == targetDate) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.colorIndex, colorIndex) ||
                other.colorIndex == colorIndex) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    targetDate,
    emoji,
    colorIndex,
    sortOrder,
    createdAt,
  );

  /// Create a copy of DayCounter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DayCounterImplCopyWith<_$DayCounterImpl> get copyWith =>
      __$$DayCounterImplCopyWithImpl<_$DayCounterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DayCounterImplToJson(this);
  }
}

abstract class _DayCounter extends DayCounter {
  const factory _DayCounter({
    final int? id,
    required final String title,
    required final String targetDate,
    final String emoji,
    final int colorIndex,
    final int sortOrder,
    final String? createdAt,
  }) = _$DayCounterImpl;
  const _DayCounter._() : super._();

  factory _DayCounter.fromJson(Map<String, dynamic> json) =
      _$DayCounterImpl.fromJson;

  @override
  int? get id;
  @override
  String get title;
  @override
  String get targetDate;
  @override
  String get emoji;
  @override
  int get colorIndex;
  @override
  int get sortOrder;
  @override
  String? get createdAt;

  /// Create a copy of DayCounter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DayCounterImplCopyWith<_$DayCounterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
