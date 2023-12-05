// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_time.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MealTime _$MealTimeFromJson(Map<String, dynamic> json) {
  return _MealTime.fromJson(json);
}

/// @nodoc
mixin _$MealTime {
  MealType get mealType => throw _privateConstructorUsedError;
  int get weekDay => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MealTimeCopyWith<MealTime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealTimeCopyWith<$Res> {
  factory $MealTimeCopyWith(MealTime value, $Res Function(MealTime) then) =
      _$MealTimeCopyWithImpl<$Res, MealTime>;
  @useResult
  $Res call({MealType mealType, int weekDay});
}

/// @nodoc
class _$MealTimeCopyWithImpl<$Res, $Val extends MealTime>
    implements $MealTimeCopyWith<$Res> {
  _$MealTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mealType = null,
    Object? weekDay = null,
  }) {
    return _then(_value.copyWith(
      mealType: null == mealType
          ? _value.mealType
          : mealType // ignore: cast_nullable_to_non_nullable
              as MealType,
      weekDay: null == weekDay
          ? _value.weekDay
          : weekDay // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MealTimeImplCopyWith<$Res>
    implements $MealTimeCopyWith<$Res> {
  factory _$$MealTimeImplCopyWith(
          _$MealTimeImpl value, $Res Function(_$MealTimeImpl) then) =
      __$$MealTimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({MealType mealType, int weekDay});
}

/// @nodoc
class __$$MealTimeImplCopyWithImpl<$Res>
    extends _$MealTimeCopyWithImpl<$Res, _$MealTimeImpl>
    implements _$$MealTimeImplCopyWith<$Res> {
  __$$MealTimeImplCopyWithImpl(
      _$MealTimeImpl _value, $Res Function(_$MealTimeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mealType = null,
    Object? weekDay = null,
  }) {
    return _then(_$MealTimeImpl(
      mealType: null == mealType
          ? _value.mealType
          : mealType // ignore: cast_nullable_to_non_nullable
              as MealType,
      weekDay: null == weekDay
          ? _value.weekDay
          : weekDay // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MealTimeImpl with DiagnosticableTreeMixin implements _MealTime {
  const _$MealTimeImpl({required this.mealType, required this.weekDay});

  factory _$MealTimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealTimeImplFromJson(json);

  @override
  final MealType mealType;
  @override
  final int weekDay;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MealTime(mealType: $mealType, weekDay: $weekDay)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MealTime'))
      ..add(DiagnosticsProperty('mealType', mealType))
      ..add(DiagnosticsProperty('weekDay', weekDay));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealTimeImpl &&
            (identical(other.mealType, mealType) ||
                other.mealType == mealType) &&
            (identical(other.weekDay, weekDay) || other.weekDay == weekDay));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, mealType, weekDay);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MealTimeImplCopyWith<_$MealTimeImpl> get copyWith =>
      __$$MealTimeImplCopyWithImpl<_$MealTimeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealTimeImplToJson(
      this,
    );
  }
}

abstract class _MealTime implements MealTime {
  const factory _MealTime(
      {required final MealType mealType,
      required final int weekDay}) = _$MealTimeImpl;

  factory _MealTime.fromJson(Map<String, dynamic> json) =
      _$MealTimeImpl.fromJson;

  @override
  MealType get mealType;
  @override
  int get weekDay;
  @override
  @JsonKey(ignore: true)
  _$$MealTimeImplCopyWith<_$MealTimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
