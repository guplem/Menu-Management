// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cooking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Cooking {

 Recipe get recipe;/// The amount of meals to cook. [yield] =~ meals. 0 means it should already be cooked. Total servings = people * [yield]
 int get yield;
/// Create a copy of Cooking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CookingCopyWith<Cooking> get copyWith => _$CookingCopyWithImpl<Cooking>(this as Cooking, _$identity);

  /// Serializes this Cooking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cooking&&(identical(other.recipe, recipe) || other.recipe == recipe)&&(identical(other.yield, yield) || other.yield == yield));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipe,yield);

@override
String toString() {
  return 'Cooking(recipe: $recipe, yield: $yield)';
}


}

/// @nodoc
abstract mixin class $CookingCopyWith<$Res>  {
  factory $CookingCopyWith(Cooking value, $Res Function(Cooking) _then) = _$CookingCopyWithImpl;
@useResult
$Res call({
 Recipe recipe, int yield
});


$RecipeCopyWith<$Res> get recipe;

}
/// @nodoc
class _$CookingCopyWithImpl<$Res>
    implements $CookingCopyWith<$Res> {
  _$CookingCopyWithImpl(this._self, this._then);

  final Cooking _self;
  final $Res Function(Cooking) _then;

/// Create a copy of Cooking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipe = null,Object? yield = null,}) {
  return _then(_self.copyWith(
recipe: null == recipe ? _self.recipe : recipe // ignore: cast_nullable_to_non_nullable
as Recipe,yield: null == yield ? _self.yield : yield // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Cooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecipeCopyWith<$Res> get recipe {
  
  return $RecipeCopyWith<$Res>(_self.recipe, (value) {
    return _then(_self.copyWith(recipe: value));
  });
}
}


/// Adds pattern-matching-related methods to [Cooking].
extension CookingPatterns on Cooking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cooking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cooking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cooking value)  $default,){
final _that = this;
switch (_that) {
case _Cooking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cooking value)?  $default,){
final _that = this;
switch (_that) {
case _Cooking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Recipe recipe,  int yield)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cooking() when $default != null:
return $default(_that.recipe,_that.yield);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Recipe recipe,  int yield)  $default,) {final _that = this;
switch (_that) {
case _Cooking():
return $default(_that.recipe,_that.yield);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Recipe recipe,  int yield)?  $default,) {final _that = this;
switch (_that) {
case _Cooking() when $default != null:
return $default(_that.recipe,_that.yield);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Cooking implements Cooking {
  const _Cooking({required this.recipe, required this.yield});
  factory _Cooking.fromJson(Map<String, dynamic> json) => _$CookingFromJson(json);

@override final  Recipe recipe;
/// The amount of meals to cook. [yield] =~ meals. 0 means it should already be cooked. Total servings = people * [yield]
@override final  int yield;

/// Create a copy of Cooking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CookingCopyWith<_Cooking> get copyWith => __$CookingCopyWithImpl<_Cooking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cooking&&(identical(other.recipe, recipe) || other.recipe == recipe)&&(identical(other.yield, yield) || other.yield == yield));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipe,yield);

@override
String toString() {
  return 'Cooking(recipe: $recipe, yield: $yield)';
}


}

/// @nodoc
abstract mixin class _$CookingCopyWith<$Res> implements $CookingCopyWith<$Res> {
  factory _$CookingCopyWith(_Cooking value, $Res Function(_Cooking) _then) = __$CookingCopyWithImpl;
@override @useResult
$Res call({
 Recipe recipe, int yield
});


@override $RecipeCopyWith<$Res> get recipe;

}
/// @nodoc
class __$CookingCopyWithImpl<$Res>
    implements _$CookingCopyWith<$Res> {
  __$CookingCopyWithImpl(this._self, this._then);

  final _Cooking _self;
  final $Res Function(_Cooking) _then;

/// Create a copy of Cooking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipe = null,Object? yield = null,}) {
  return _then(_Cooking(
recipe: null == recipe ? _self.recipe : recipe // ignore: cast_nullable_to_non_nullable
as Recipe,yield: null == yield ? _self.yield : yield // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Cooking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecipeCopyWith<$Res> get recipe {
  
  return $RecipeCopyWith<$Res>(_self.recipe, (value) {
    return _then(_self.copyWith(recipe: value));
  });
}
}

// dart format on
