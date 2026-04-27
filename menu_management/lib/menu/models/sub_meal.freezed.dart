// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_meal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubMeal {

 Cooking? get cooking; int get people;
/// Create a copy of SubMeal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubMealCopyWith<SubMeal> get copyWith => _$SubMealCopyWithImpl<SubMeal>(this as SubMeal, _$identity);

  /// Serializes this SubMeal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubMeal&&(identical(other.cooking, cooking) || other.cooking == cooking)&&(identical(other.people, people) || other.people == people));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cooking,people);

@override
String toString() {
  return 'SubMeal(cooking: $cooking, people: $people)';
}


}

/// @nodoc
abstract mixin class $SubMealCopyWith<$Res>  {
  factory $SubMealCopyWith(SubMeal value, $Res Function(SubMeal) _then) = _$SubMealCopyWithImpl;
@useResult
$Res call({
 Cooking? cooking, int people
});


$CookingCopyWith<$Res>? get cooking;

}
/// @nodoc
class _$SubMealCopyWithImpl<$Res>
    implements $SubMealCopyWith<$Res> {
  _$SubMealCopyWithImpl(this._self, this._then);

  final SubMeal _self;
  final $Res Function(SubMeal) _then;

/// Create a copy of SubMeal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cooking = freezed,Object? people = null,}) {
  return _then(_self.copyWith(
cooking: freezed == cooking ? _self.cooking : cooking // ignore: cast_nullable_to_non_nullable
as Cooking?,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SubMeal
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
}
}


/// Adds pattern-matching-related methods to [SubMeal].
extension SubMealPatterns on SubMeal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubMeal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubMeal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubMeal value)  $default,){
final _that = this;
switch (_that) {
case _SubMeal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubMeal value)?  $default,){
final _that = this;
switch (_that) {
case _SubMeal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Cooking? cooking,  int people)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubMeal() when $default != null:
return $default(_that.cooking,_that.people);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Cooking? cooking,  int people)  $default,) {final _that = this;
switch (_that) {
case _SubMeal():
return $default(_that.cooking,_that.people);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Cooking? cooking,  int people)?  $default,) {final _that = this;
switch (_that) {
case _SubMeal() when $default != null:
return $default(_that.cooking,_that.people);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubMeal implements SubMeal {
  const _SubMeal({this.cooking, this.people = 1});
  factory _SubMeal.fromJson(Map<String, dynamic> json) => _$SubMealFromJson(json);

@override final  Cooking? cooking;
@override@JsonKey() final  int people;

/// Create a copy of SubMeal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubMealCopyWith<_SubMeal> get copyWith => __$SubMealCopyWithImpl<_SubMeal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubMealToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubMeal&&(identical(other.cooking, cooking) || other.cooking == cooking)&&(identical(other.people, people) || other.people == people));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cooking,people);

@override
String toString() {
  return 'SubMeal(cooking: $cooking, people: $people)';
}


}

/// @nodoc
abstract mixin class _$SubMealCopyWith<$Res> implements $SubMealCopyWith<$Res> {
  factory _$SubMealCopyWith(_SubMeal value, $Res Function(_SubMeal) _then) = __$SubMealCopyWithImpl;
@override @useResult
$Res call({
 Cooking? cooking, int people
});


@override $CookingCopyWith<$Res>? get cooking;

}
/// @nodoc
class __$SubMealCopyWithImpl<$Res>
    implements _$SubMealCopyWith<$Res> {
  __$SubMealCopyWithImpl(this._self, this._then);

  final _SubMeal _self;
  final $Res Function(_SubMeal) _then;

/// Create a copy of SubMeal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cooking = freezed,Object? people = null,}) {
  return _then(_SubMeal(
cooking: freezed == cooking ? _self.cooking : cooking // ignore: cast_nullable_to_non_nullable
as Cooking?,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SubMeal
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
}
}

// dart format on
