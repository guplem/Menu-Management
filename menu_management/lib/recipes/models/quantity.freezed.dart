// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quantity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Quantity {

 double get amount; Unit get unit;
/// Create a copy of Quantity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuantityCopyWith<Quantity> get copyWith => _$QuantityCopyWithImpl<Quantity>(this as Quantity, _$identity);

  /// Serializes this Quantity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Quantity&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,unit);

@override
String toString() {
  return 'Quantity(amount: $amount, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $QuantityCopyWith<$Res>  {
  factory $QuantityCopyWith(Quantity value, $Res Function(Quantity) _then) = _$QuantityCopyWithImpl;
@useResult
$Res call({
 double amount, Unit unit
});




}
/// @nodoc
class _$QuantityCopyWithImpl<$Res>
    implements $QuantityCopyWith<$Res> {
  _$QuantityCopyWithImpl(this._self, this._then);

  final Quantity _self;
  final $Res Function(Quantity) _then;

/// Create a copy of Quantity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? unit = null,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as Unit,
  ));
}

}


/// Adds pattern-matching-related methods to [Quantity].
extension QuantityPatterns on Quantity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Quantity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Quantity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Quantity value)  $default,){
final _that = this;
switch (_that) {
case _Quantity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Quantity value)?  $default,){
final _that = this;
switch (_that) {
case _Quantity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double amount,  Unit unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Quantity() when $default != null:
return $default(_that.amount,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double amount,  Unit unit)  $default,) {final _that = this;
switch (_that) {
case _Quantity():
return $default(_that.amount,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double amount,  Unit unit)?  $default,) {final _that = this;
switch (_that) {
case _Quantity() when $default != null:
return $default(_that.amount,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Quantity implements Quantity {
  const _Quantity({required this.amount, required this.unit});
  factory _Quantity.fromJson(Map<String, dynamic> json) => _$QuantityFromJson(json);

@override final  double amount;
@override final  Unit unit;

/// Create a copy of Quantity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuantityCopyWith<_Quantity> get copyWith => __$QuantityCopyWithImpl<_Quantity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuantityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Quantity&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,unit);

@override
String toString() {
  return 'Quantity(amount: $amount, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$QuantityCopyWith<$Res> implements $QuantityCopyWith<$Res> {
  factory _$QuantityCopyWith(_Quantity value, $Res Function(_Quantity) _then) = __$QuantityCopyWithImpl;
@override @useResult
$Res call({
 double amount, Unit unit
});




}
/// @nodoc
class __$QuantityCopyWithImpl<$Res>
    implements _$QuantityCopyWith<$Res> {
  __$QuantityCopyWithImpl(this._self, this._then);

  final _Quantity _self;
  final $Res Function(_Quantity) _then;

/// Create a copy of Quantity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? unit = null,}) {
  return _then(_Quantity(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as Unit,
  ));
}


}

// dart format on
