// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MenuConfiguration {

 MealTime get mealTime; bool get requiresMeal; int get availableCookingTimeMinutes;
/// Create a copy of MenuConfiguration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuConfigurationCopyWith<MenuConfiguration> get copyWith => _$MenuConfigurationCopyWithImpl<MenuConfiguration>(this as MenuConfiguration, _$identity);

  /// Serializes this MenuConfiguration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuConfiguration&&(identical(other.mealTime, mealTime) || other.mealTime == mealTime)&&(identical(other.requiresMeal, requiresMeal) || other.requiresMeal == requiresMeal)&&(identical(other.availableCookingTimeMinutes, availableCookingTimeMinutes) || other.availableCookingTimeMinutes == availableCookingTimeMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mealTime,requiresMeal,availableCookingTimeMinutes);

@override
String toString() {
  return 'MenuConfiguration(mealTime: $mealTime, requiresMeal: $requiresMeal, availableCookingTimeMinutes: $availableCookingTimeMinutes)';
}


}

/// @nodoc
abstract mixin class $MenuConfigurationCopyWith<$Res>  {
  factory $MenuConfigurationCopyWith(MenuConfiguration value, $Res Function(MenuConfiguration) _then) = _$MenuConfigurationCopyWithImpl;
@useResult
$Res call({
 MealTime mealTime, bool requiresMeal, int availableCookingTimeMinutes
});


$MealTimeCopyWith<$Res> get mealTime;

}
/// @nodoc
class _$MenuConfigurationCopyWithImpl<$Res>
    implements $MenuConfigurationCopyWith<$Res> {
  _$MenuConfigurationCopyWithImpl(this._self, this._then);

  final MenuConfiguration _self;
  final $Res Function(MenuConfiguration) _then;

/// Create a copy of MenuConfiguration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mealTime = null,Object? requiresMeal = null,Object? availableCookingTimeMinutes = null,}) {
  return _then(_self.copyWith(
mealTime: null == mealTime ? _self.mealTime : mealTime // ignore: cast_nullable_to_non_nullable
as MealTime,requiresMeal: null == requiresMeal ? _self.requiresMeal : requiresMeal // ignore: cast_nullable_to_non_nullable
as bool,availableCookingTimeMinutes: null == availableCookingTimeMinutes ? _self.availableCookingTimeMinutes : availableCookingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of MenuConfiguration
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MealTimeCopyWith<$Res> get mealTime {
  
  return $MealTimeCopyWith<$Res>(_self.mealTime, (value) {
    return _then(_self.copyWith(mealTime: value));
  });
}
}


/// Adds pattern-matching-related methods to [MenuConfiguration].
extension MenuConfigurationPatterns on MenuConfiguration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuConfiguration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuConfiguration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuConfiguration value)  $default,){
final _that = this;
switch (_that) {
case _MenuConfiguration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuConfiguration value)?  $default,){
final _that = this;
switch (_that) {
case _MenuConfiguration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MealTime mealTime,  bool requiresMeal,  int availableCookingTimeMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuConfiguration() when $default != null:
return $default(_that.mealTime,_that.requiresMeal,_that.availableCookingTimeMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MealTime mealTime,  bool requiresMeal,  int availableCookingTimeMinutes)  $default,) {final _that = this;
switch (_that) {
case _MenuConfiguration():
return $default(_that.mealTime,_that.requiresMeal,_that.availableCookingTimeMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MealTime mealTime,  bool requiresMeal,  int availableCookingTimeMinutes)?  $default,) {final _that = this;
switch (_that) {
case _MenuConfiguration() when $default != null:
return $default(_that.mealTime,_that.requiresMeal,_that.availableCookingTimeMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuConfiguration extends MenuConfiguration {
  const _MenuConfiguration({required this.mealTime, this.requiresMeal = true, this.availableCookingTimeMinutes = 60}): super._();
  factory _MenuConfiguration.fromJson(Map<String, dynamic> json) => _$MenuConfigurationFromJson(json);

@override final  MealTime mealTime;
@override@JsonKey() final  bool requiresMeal;
@override@JsonKey() final  int availableCookingTimeMinutes;

/// Create a copy of MenuConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuConfigurationCopyWith<_MenuConfiguration> get copyWith => __$MenuConfigurationCopyWithImpl<_MenuConfiguration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuConfigurationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuConfiguration&&(identical(other.mealTime, mealTime) || other.mealTime == mealTime)&&(identical(other.requiresMeal, requiresMeal) || other.requiresMeal == requiresMeal)&&(identical(other.availableCookingTimeMinutes, availableCookingTimeMinutes) || other.availableCookingTimeMinutes == availableCookingTimeMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mealTime,requiresMeal,availableCookingTimeMinutes);

@override
String toString() {
  return 'MenuConfiguration(mealTime: $mealTime, requiresMeal: $requiresMeal, availableCookingTimeMinutes: $availableCookingTimeMinutes)';
}


}

/// @nodoc
abstract mixin class _$MenuConfigurationCopyWith<$Res> implements $MenuConfigurationCopyWith<$Res> {
  factory _$MenuConfigurationCopyWith(_MenuConfiguration value, $Res Function(_MenuConfiguration) _then) = __$MenuConfigurationCopyWithImpl;
@override @useResult
$Res call({
 MealTime mealTime, bool requiresMeal, int availableCookingTimeMinutes
});


@override $MealTimeCopyWith<$Res> get mealTime;

}
/// @nodoc
class __$MenuConfigurationCopyWithImpl<$Res>
    implements _$MenuConfigurationCopyWith<$Res> {
  __$MenuConfigurationCopyWithImpl(this._self, this._then);

  final _MenuConfiguration _self;
  final $Res Function(_MenuConfiguration) _then;

/// Create a copy of MenuConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mealTime = null,Object? requiresMeal = null,Object? availableCookingTimeMinutes = null,}) {
  return _then(_MenuConfiguration(
mealTime: null == mealTime ? _self.mealTime : mealTime // ignore: cast_nullable_to_non_nullable
as MealTime,requiresMeal: null == requiresMeal ? _self.requiresMeal : requiresMeal // ignore: cast_nullable_to_non_nullable
as bool,availableCookingTimeMinutes: null == availableCookingTimeMinutes ? _self.availableCookingTimeMinutes : availableCookingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of MenuConfiguration
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
