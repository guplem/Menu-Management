// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Meal _$MealFromJson(Map<String, dynamic> json) {
  return _Meal.fromJson(json);
}

/// @nodoc
mixin _$Meal {
  List<Cooking> get cookings => throw _privateConstructorUsedError;
  MealTime get mealTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MealCopyWith<Meal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealCopyWith<$Res> {
  factory $MealCopyWith(Meal value, $Res Function(Meal) then) =
      _$MealCopyWithImpl<$Res, Meal>;
  @useResult
  $Res call({List<Cooking> cookings, MealTime mealTime});

  $MealTimeCopyWith<$Res> get mealTime;
}

/// @nodoc
class _$MealCopyWithImpl<$Res, $Val extends Meal>
    implements $MealCopyWith<$Res> {
  _$MealCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cookings = null,
    Object? mealTime = null,
  }) {
    return _then(_value.copyWith(
      cookings: null == cookings
          ? _value.cookings
          : cookings // ignore: cast_nullable_to_non_nullable
              as List<Cooking>,
      mealTime: null == mealTime
          ? _value.mealTime
          : mealTime // ignore: cast_nullable_to_non_nullable
              as MealTime,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MealTimeCopyWith<$Res> get mealTime {
    return $MealTimeCopyWith<$Res>(_value.mealTime, (value) {
      return _then(_value.copyWith(mealTime: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MealImplCopyWith<$Res> implements $MealCopyWith<$Res> {
  factory _$$MealImplCopyWith(
          _$MealImpl value, $Res Function(_$MealImpl) then) =
      __$$MealImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Cooking> cookings, MealTime mealTime});

  @override
  $MealTimeCopyWith<$Res> get mealTime;
}

/// @nodoc
class __$$MealImplCopyWithImpl<$Res>
    extends _$MealCopyWithImpl<$Res, _$MealImpl>
    implements _$$MealImplCopyWith<$Res> {
  __$$MealImplCopyWithImpl(_$MealImpl _value, $Res Function(_$MealImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cookings = null,
    Object? mealTime = null,
  }) {
    return _then(_$MealImpl(
      cookings: null == cookings
          ? _value._cookings
          : cookings // ignore: cast_nullable_to_non_nullable
              as List<Cooking>,
      mealTime: null == mealTime
          ? _value.mealTime
          : mealTime // ignore: cast_nullable_to_non_nullable
              as MealTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MealImpl extends _Meal with DiagnosticableTreeMixin {
  const _$MealImpl(
      {required final List<Cooking> cookings, required this.mealTime})
      : _cookings = cookings,
        super._();

  factory _$MealImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealImplFromJson(json);

  final List<Cooking> _cookings;
  @override
  List<Cooking> get cookings {
    if (_cookings is EqualUnmodifiableListView) return _cookings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cookings);
  }

  @override
  final MealTime mealTime;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Meal(cookings: $cookings, mealTime: $mealTime)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Meal'))
      ..add(DiagnosticsProperty('cookings', cookings))
      ..add(DiagnosticsProperty('mealTime', mealTime));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealImpl &&
            const DeepCollectionEquality().equals(other._cookings, _cookings) &&
            (identical(other.mealTime, mealTime) ||
                other.mealTime == mealTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_cookings), mealTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MealImplCopyWith<_$MealImpl> get copyWith =>
      __$$MealImplCopyWithImpl<_$MealImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealImplToJson(
      this,
    );
  }
}

abstract class _Meal extends Meal {
  const factory _Meal(
      {required final List<Cooking> cookings,
      required final MealTime mealTime}) = _$MealImpl;
  const _Meal._() : super._();

  factory _Meal.fromJson(Map<String, dynamic> json) = _$MealImpl.fromJson;

  @override
  List<Cooking> get cookings;
  @override
  MealTime get mealTime;
  @override
  @JsonKey(ignore: true)
  _$$MealImplCopyWith<_$MealImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
