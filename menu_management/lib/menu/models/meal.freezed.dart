// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Meal {

 Cooking? get cooking; MealTime get mealTime; int get people;
/// Create a copy of Meal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MealCopyWith<Meal> get copyWith => _$MealCopyWithImpl<Meal>(this as Meal, _$identity);

  /// Serializes this Meal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Meal&&(identical(other.cooking, cooking) || other.cooking == cooking)&&(identical(other.mealTime, mealTime) || other.mealTime == mealTime)&&(identical(other.people, people) || other.people == people));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cooking,mealTime,people);

@override
String toString() {
  return 'Meal(cooking: $cooking, mealTime: $mealTime, people: $people)';
}


}

/// @nodoc
abstract mixin class $MealCopyWith<$Res>  {
  factory $MealCopyWith(Meal value, $Res Function(Meal) _then) = _$MealCopyWithImpl;
@useResult
$Res call({
 Cooking? cooking, MealTime mealTime, int people
});


$CookingCopyWith<$Res>? get cooking;$MealTimeCopyWith<$Res> get mealTime;

}
/// @nodoc
class _$MealCopyWithImpl<$Res>
    implements $MealCopyWith<$Res> {
  _$MealCopyWithImpl(this._self, this._then);

  final Meal _self;
  final $Res Function(Meal) _then;

/// Create a copy of Meal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cooking = freezed,Object? mealTime = null,Object? people = null,}) {
  return _then(_self.copyWith(
cooking: freezed == cooking ? _self.cooking : cooking // ignore: cast_nullable_to_non_nullable
as Cooking?,mealTime: null == mealTime ? _self.mealTime : mealTime // ignore: cast_nullable_to_non_nullable
as MealTime,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Meal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CookingCopyWith<$Res>? get cooking {
    if (_self.cooking == null) {
    return null;
  }

  return $CookingCopyWith<$Res>(_self.cooking!, (value) {
    return _then(_self.copyWith(cooking: value));
  });
}/// Create a copy of Meal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MealTimeCopyWith<$Res> get mealTime {
  
  return $MealTimeCopyWith<$Res>(_self.mealTime, (value) {
    return _then(_self.copyWith(mealTime: value));
  });
}
}


/// Adds pattern-matching-related methods to [Meal].
extension MealPatterns on Meal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Meal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Meal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Meal value)  $default,){
final _that = this;
switch (_that) {
case _Meal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Meal value)?  $default,){
final _that = this;
switch (_that) {
case _Meal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Cooking? cooking,  MealTime mealTime,  int people)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Meal() when $default != null:
return $default(_that.cooking,_that.mealTime,_that.people);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Cooking? cooking,  MealTime mealTime,  int people)  $default,) {final _that = this;
switch (_that) {
case _Meal():
return $default(_that.cooking,_that.mealTime,_that.people);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Cooking? cooking,  MealTime mealTime,  int people)?  $default,) {final _that = this;
switch (_that) {
case _Meal() when $default != null:
return $default(_that.cooking,_that.mealTime,_that.people);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Meal extends Meal {
  const _Meal({required this.cooking, required this.mealTime, this.people = 2}): super._();
  factory _Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);

@override final  Cooking? cooking;
@override final  MealTime mealTime;
@override@JsonKey() final  int people;

/// Create a copy of Meal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MealCopyWith<_Meal> get copyWith => __$MealCopyWithImpl<_Meal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MealToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Meal&&(identical(other.cooking, cooking) || other.cooking == cooking)&&(identical(other.mealTime, mealTime) || other.mealTime == mealTime)&&(identical(other.people, people) || other.people == people));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cooking,mealTime,people);

@override
String toString() {
  return 'Meal(cooking: $cooking, mealTime: $mealTime, people: $people)';
}


}

/// @nodoc
abstract mixin class _$MealCopyWith<$Res> implements $MealCopyWith<$Res> {
  factory _$MealCopyWith(_Meal value, $Res Function(_Meal) _then) = __$MealCopyWithImpl;
@override @useResult
$Res call({
 Cooking? cooking, MealTime mealTime, int people
});


@override $CookingCopyWith<$Res>? get cooking;@override $MealTimeCopyWith<$Res> get mealTime;

}
/// @nodoc
class __$MealCopyWithImpl<$Res>
    implements _$MealCopyWith<$Res> {
  __$MealCopyWithImpl(this._self, this._then);

  final _Meal _self;
  final $Res Function(_Meal) _then;

/// Create a copy of Meal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cooking = freezed,Object? mealTime = null,Object? people = null,}) {
  return _then(_Meal(
cooking: freezed == cooking ? _self.cooking : cooking // ignore: cast_nullable_to_non_nullable
as Cooking?,mealTime: null == mealTime ? _self.mealTime : mealTime // ignore: cast_nullable_to_non_nullable
as MealTime,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Meal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CookingCopyWith<$Res>? get cooking {
    if (_self.cooking == null) {
    return null;
  }

  return $CookingCopyWith<$Res>(_self.cooking!, (value) {
    return _then(_self.copyWith(cooking: value));
  });
}/// Create a copy of Meal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MealTimeCopyWith<$Res> get mealTime {
  
  return $MealTimeCopyWith<$Res>(_self.mealTime, (value) {
    return _then(_self.copyWith(mealTime: value));
  });
}
}

// dart format on
