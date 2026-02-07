// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IngredientUsage {

 String get ingredient; Quantity get quantity;
/// Create a copy of IngredientUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientUsageCopyWith<IngredientUsage> get copyWith => _$IngredientUsageCopyWithImpl<IngredientUsage>(this as IngredientUsage, _$identity);

  /// Serializes this IngredientUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngredientUsage&&(identical(other.ingredient, ingredient) || other.ingredient == ingredient)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ingredient,quantity);

@override
String toString() {
  return 'IngredientUsage(ingredient: $ingredient, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $IngredientUsageCopyWith<$Res>  {
  factory $IngredientUsageCopyWith(IngredientUsage value, $Res Function(IngredientUsage) _then) = _$IngredientUsageCopyWithImpl;
@useResult
$Res call({
 String ingredient, Quantity quantity
});


$QuantityCopyWith<$Res> get quantity;

}
/// @nodoc
class _$IngredientUsageCopyWithImpl<$Res>
    implements $IngredientUsageCopyWith<$Res> {
  _$IngredientUsageCopyWithImpl(this._self, this._then);

  final IngredientUsage _self;
  final $Res Function(IngredientUsage) _then;

/// Create a copy of IngredientUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ingredient = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
ingredient: null == ingredient ? _self.ingredient : ingredient // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,
  ));
}
/// Create a copy of IngredientUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityCopyWith<$Res> get quantity {
  
  return $QuantityCopyWith<$Res>(_self.quantity, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}
}


/// Adds pattern-matching-related methods to [IngredientUsage].
extension IngredientUsagePatterns on IngredientUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngredientUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngredientUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngredientUsage value)  $default,){
final _that = this;
switch (_that) {
case _IngredientUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngredientUsage value)?  $default,){
final _that = this;
switch (_that) {
case _IngredientUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ingredient,  Quantity quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngredientUsage() when $default != null:
return $default(_that.ingredient,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ingredient,  Quantity quantity)  $default,) {final _that = this;
switch (_that) {
case _IngredientUsage():
return $default(_that.ingredient,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ingredient,  Quantity quantity)?  $default,) {final _that = this;
switch (_that) {
case _IngredientUsage() when $default != null:
return $default(_that.ingredient,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IngredientUsage implements IngredientUsage {
  const _IngredientUsage({required this.ingredient, required this.quantity});
  factory _IngredientUsage.fromJson(Map<String, dynamic> json) => _$IngredientUsageFromJson(json);

@override final  String ingredient;
@override final  Quantity quantity;

/// Create a copy of IngredientUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngredientUsageCopyWith<_IngredientUsage> get copyWith => __$IngredientUsageCopyWithImpl<_IngredientUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IngredientUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngredientUsage&&(identical(other.ingredient, ingredient) || other.ingredient == ingredient)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ingredient,quantity);

@override
String toString() {
  return 'IngredientUsage(ingredient: $ingredient, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$IngredientUsageCopyWith<$Res> implements $IngredientUsageCopyWith<$Res> {
  factory _$IngredientUsageCopyWith(_IngredientUsage value, $Res Function(_IngredientUsage) _then) = __$IngredientUsageCopyWithImpl;
@override @useResult
$Res call({
 String ingredient, Quantity quantity
});


@override $QuantityCopyWith<$Res> get quantity;

}
/// @nodoc
class __$IngredientUsageCopyWithImpl<$Res>
    implements _$IngredientUsageCopyWith<$Res> {
  __$IngredientUsageCopyWithImpl(this._self, this._then);

  final _IngredientUsage _self;
  final $Res Function(_IngredientUsage) _then;

/// Create a copy of IngredientUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ingredient = null,Object? quantity = null,}) {
  return _then(_IngredientUsage(
ingredient: null == ingredient ? _self.ingredient : ingredient // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,
  ));
}

/// Create a copy of IngredientUsage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityCopyWith<$Res> get quantity {
  
  return $QuantityCopyWith<$Res>(_self.quantity, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}
}

// dart format on
