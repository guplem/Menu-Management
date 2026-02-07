// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_time.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MealTime {

/// 0 = Saturday, 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday
 WeekDay get weekDay; MealType get mealType;
/// Create a copy of MealTime
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealTimeCopyWith<MealTime> get copyWith => _$MealTimeCopyWithImpl<MealTime>(this as MealTime, _$identity);

  /// Serializes this MealTime to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MealTime&&(identical(other.weekDay, weekDay) || other.weekDay == weekDay)&&(identical(other.mealType, mealType) || other.mealType == mealType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekDay,mealType);

@override
String toString() {
  return 'MealTime(weekDay: $weekDay, mealType: $mealType)';
}


}

/// @nodoc
abstract mixin class $MealTimeCopyWith<$Res>  {
  factory $MealTimeCopyWith(MealTime value, $Res Function(MealTime) _then) = _$MealTimeCopyWithImpl;
@useResult
$Res call({
 WeekDay weekDay, MealType mealType
});




}
/// @nodoc
class _$MealTimeCopyWithImpl<$Res>
    implements $MealTimeCopyWith<$Res> {
  _$MealTimeCopyWithImpl(this._self, this._then);

  final MealTime _self;
  final $Res Function(MealTime) _then;

/// Create a copy of MealTime
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekDay = null,Object? mealType = null,}) {
  return _then(_self.copyWith(
weekDay: null == weekDay ? _self.weekDay : weekDay // ignore: cast_nullable_to_non_nullable
as WeekDay,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,
  ));
}

}


/// Adds pattern-matching-related methods to [MealTime].
extension MealTimePatterns on MealTime {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MealTime value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MealTime() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MealTime value)  $default,){
final _that = this;
switch (_that) {
case _MealTime():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MealTime value)?  $default,){
final _that = this;
switch (_that) {
case _MealTime() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WeekDay weekDay,  MealType mealType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MealTime() when $default != null:
return $default(_that.weekDay,_that.mealType);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WeekDay weekDay,  MealType mealType)  $default,) {final _that = this;
switch (_that) {
case _MealTime():
return $default(_that.weekDay,_that.mealType);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WeekDay weekDay,  MealType mealType)?  $default,) {final _that = this;
switch (_that) {
case _MealTime() when $default != null:
return $default(_that.weekDay,_that.mealType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MealTime extends MealTime {
  const _MealTime({required this.weekDay, required this.mealType}): super._();
  factory _MealTime.fromJson(Map<String, dynamic> json) => _$MealTimeFromJson(json);

/// 0 = Saturday, 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday
@override final  WeekDay weekDay;
@override final  MealType mealType;

/// Create a copy of MealTime
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealTimeCopyWith<_MealTime> get copyWith => __$MealTimeCopyWithImpl<_MealTime>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealTimeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MealTime&&(identical(other.weekDay, weekDay) || other.weekDay == weekDay)&&(identical(other.mealType, mealType) || other.mealType == mealType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekDay,mealType);

@override
String toString() {
  return 'MealTime(weekDay: $weekDay, mealType: $mealType)';
}


}

/// @nodoc
abstract mixin class _$MealTimeCopyWith<$Res> implements $MealTimeCopyWith<$Res> {
  factory _$MealTimeCopyWith(_MealTime value, $Res Function(_MealTime) _then) = __$MealTimeCopyWithImpl;
@override @useResult
$Res call({
 WeekDay weekDay, MealType mealType
});




}
/// @nodoc
class __$MealTimeCopyWithImpl<$Res>
    implements _$MealTimeCopyWith<$Res> {
  __$MealTimeCopyWithImpl(this._self, this._then);

  final _MealTime _self;
  final $Res Function(_MealTime) _then;

/// Create a copy of MealTime
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekDay = null,Object? mealType = null,}) {
  return _then(_MealTime(
weekDay: null == weekDay ? _self.weekDay : weekDay // ignore: cast_nullable_to_non_nullable
as WeekDay,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,
  ));
}


}

// dart format on
