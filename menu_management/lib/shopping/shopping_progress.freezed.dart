// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShoppingProgress {

 Map<String, OwnedAmountProgress> get ownedAmounts; Map<String, Map<ProductCountKey, double>> get ownedProductCounts; bool get useFreezerStrategy;
/// Create a copy of ShoppingProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingProgressCopyWith<ShoppingProgress> get copyWith => _$ShoppingProgressCopyWithImpl<ShoppingProgress>(this as ShoppingProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingProgress&&const DeepCollectionEquality().equals(other.ownedAmounts, ownedAmounts)&&const DeepCollectionEquality().equals(other.ownedProductCounts, ownedProductCounts)&&(identical(other.useFreezerStrategy, useFreezerStrategy) || other.useFreezerStrategy == useFreezerStrategy));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(ownedAmounts),const DeepCollectionEquality().hash(ownedProductCounts),useFreezerStrategy);

@override
String toString() {
  return 'ShoppingProgress(ownedAmounts: $ownedAmounts, ownedProductCounts: $ownedProductCounts, useFreezerStrategy: $useFreezerStrategy)';
}


}

/// @nodoc
abstract mixin class $ShoppingProgressCopyWith<$Res>  {
  factory $ShoppingProgressCopyWith(ShoppingProgress value, $Res Function(ShoppingProgress) _then) = _$ShoppingProgressCopyWithImpl;
@useResult
$Res call({
 Map<String, OwnedAmountProgress> ownedAmounts, Map<String, Map<ProductCountKey, double>> ownedProductCounts, bool useFreezerStrategy
});




}
/// @nodoc
class _$ShoppingProgressCopyWithImpl<$Res>
    implements $ShoppingProgressCopyWith<$Res> {
  _$ShoppingProgressCopyWithImpl(this._self, this._then);

  final ShoppingProgress _self;
  final $Res Function(ShoppingProgress) _then;

/// Create a copy of ShoppingProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ownedAmounts = null,Object? ownedProductCounts = null,Object? useFreezerStrategy = null,}) {
  return _then(_self.copyWith(
ownedAmounts: null == ownedAmounts ? _self.ownedAmounts : ownedAmounts // ignore: cast_nullable_to_non_nullable
as Map<String, OwnedAmountProgress>,ownedProductCounts: null == ownedProductCounts ? _self.ownedProductCounts : ownedProductCounts // ignore: cast_nullable_to_non_nullable
as Map<String, Map<ProductCountKey, double>>,useFreezerStrategy: null == useFreezerStrategy ? _self.useFreezerStrategy : useFreezerStrategy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingProgress].
extension ShoppingProgressPatterns on ShoppingProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingProgress value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, OwnedAmountProgress> ownedAmounts,  Map<String, Map<ProductCountKey, double>> ownedProductCounts,  bool useFreezerStrategy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingProgress() when $default != null:
return $default(_that.ownedAmounts,_that.ownedProductCounts,_that.useFreezerStrategy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, OwnedAmountProgress> ownedAmounts,  Map<String, Map<ProductCountKey, double>> ownedProductCounts,  bool useFreezerStrategy)  $default,) {final _that = this;
switch (_that) {
case _ShoppingProgress():
return $default(_that.ownedAmounts,_that.ownedProductCounts,_that.useFreezerStrategy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, OwnedAmountProgress> ownedAmounts,  Map<String, Map<ProductCountKey, double>> ownedProductCounts,  bool useFreezerStrategy)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingProgress() when $default != null:
return $default(_that.ownedAmounts,_that.ownedProductCounts,_that.useFreezerStrategy);case _:
  return null;

}
}

}

/// @nodoc


class _ShoppingProgress extends ShoppingProgress {
  const _ShoppingProgress({final  Map<String, OwnedAmountProgress> ownedAmounts = const {}, final  Map<String, Map<ProductCountKey, double>> ownedProductCounts = const {}, this.useFreezerStrategy = false}): _ownedAmounts = ownedAmounts,_ownedProductCounts = ownedProductCounts,super._();
  

 final  Map<String, OwnedAmountProgress> _ownedAmounts;
@override@JsonKey() Map<String, OwnedAmountProgress> get ownedAmounts {
  if (_ownedAmounts is EqualUnmodifiableMapView) return _ownedAmounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ownedAmounts);
}

 final  Map<String, Map<ProductCountKey, double>> _ownedProductCounts;
@override@JsonKey() Map<String, Map<ProductCountKey, double>> get ownedProductCounts {
  if (_ownedProductCounts is EqualUnmodifiableMapView) return _ownedProductCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ownedProductCounts);
}

@override@JsonKey() final  bool useFreezerStrategy;

/// Create a copy of ShoppingProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingProgressCopyWith<_ShoppingProgress> get copyWith => __$ShoppingProgressCopyWithImpl<_ShoppingProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingProgress&&const DeepCollectionEquality().equals(other._ownedAmounts, _ownedAmounts)&&const DeepCollectionEquality().equals(other._ownedProductCounts, _ownedProductCounts)&&(identical(other.useFreezerStrategy, useFreezerStrategy) || other.useFreezerStrategy == useFreezerStrategy));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_ownedAmounts),const DeepCollectionEquality().hash(_ownedProductCounts),useFreezerStrategy);

@override
String toString() {
  return 'ShoppingProgress(ownedAmounts: $ownedAmounts, ownedProductCounts: $ownedProductCounts, useFreezerStrategy: $useFreezerStrategy)';
}


}

/// @nodoc
abstract mixin class _$ShoppingProgressCopyWith<$Res> implements $ShoppingProgressCopyWith<$Res> {
  factory _$ShoppingProgressCopyWith(_ShoppingProgress value, $Res Function(_ShoppingProgress) _then) = __$ShoppingProgressCopyWithImpl;
@override @useResult
$Res call({
 Map<String, OwnedAmountProgress> ownedAmounts, Map<String, Map<ProductCountKey, double>> ownedProductCounts, bool useFreezerStrategy
});




}
/// @nodoc
class __$ShoppingProgressCopyWithImpl<$Res>
    implements _$ShoppingProgressCopyWith<$Res> {
  __$ShoppingProgressCopyWithImpl(this._self, this._then);

  final _ShoppingProgress _self;
  final $Res Function(_ShoppingProgress) _then;

/// Create a copy of ShoppingProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ownedAmounts = null,Object? ownedProductCounts = null,Object? useFreezerStrategy = null,}) {
  return _then(_ShoppingProgress(
ownedAmounts: null == ownedAmounts ? _self._ownedAmounts : ownedAmounts // ignore: cast_nullable_to_non_nullable
as Map<String, OwnedAmountProgress>,ownedProductCounts: null == ownedProductCounts ? _self._ownedProductCounts : ownedProductCounts // ignore: cast_nullable_to_non_nullable
as Map<String, Map<ProductCountKey, double>>,useFreezerStrategy: null == useFreezerStrategy ? _self.useFreezerStrategy : useFreezerStrategy // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
