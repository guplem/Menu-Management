// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IngredientSource {

 String get recipeName; List<Quantity> get perServingQuantities; int get servings;
/// Create a copy of IngredientSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientSourceCopyWith<IngredientSource> get copyWith => _$IngredientSourceCopyWithImpl<IngredientSource>(this as IngredientSource, _$identity);

  /// Serializes this IngredientSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngredientSource&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&const DeepCollectionEquality().equals(other.perServingQuantities, perServingQuantities)&&(identical(other.servings, servings) || other.servings == servings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipeName,const DeepCollectionEquality().hash(perServingQuantities),servings);

@override
String toString() {
  return 'IngredientSource(recipeName: $recipeName, perServingQuantities: $perServingQuantities, servings: $servings)';
}


}

/// @nodoc
abstract mixin class $IngredientSourceCopyWith<$Res>  {
  factory $IngredientSourceCopyWith(IngredientSource value, $Res Function(IngredientSource) _then) = _$IngredientSourceCopyWithImpl;
@useResult
$Res call({
 String recipeName, List<Quantity> perServingQuantities, int servings
});




}
/// @nodoc
class _$IngredientSourceCopyWithImpl<$Res>
    implements $IngredientSourceCopyWith<$Res> {
  _$IngredientSourceCopyWithImpl(this._self, this._then);

  final IngredientSource _self;
  final $Res Function(IngredientSource) _then;

/// Create a copy of IngredientSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipeName = null,Object? perServingQuantities = null,Object? servings = null,}) {
  return _then(_self.copyWith(
recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,perServingQuantities: null == perServingQuantities ? _self.perServingQuantities : perServingQuantities // ignore: cast_nullable_to_non_nullable
as List<Quantity>,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [IngredientSource].
extension IngredientSourcePatterns on IngredientSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngredientSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngredientSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngredientSource value)  $default,){
final _that = this;
switch (_that) {
case _IngredientSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngredientSource value)?  $default,){
final _that = this;
switch (_that) {
case _IngredientSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recipeName,  List<Quantity> perServingQuantities,  int servings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngredientSource() when $default != null:
return $default(_that.recipeName,_that.perServingQuantities,_that.servings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recipeName,  List<Quantity> perServingQuantities,  int servings)  $default,) {final _that = this;
switch (_that) {
case _IngredientSource():
return $default(_that.recipeName,_that.perServingQuantities,_that.servings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recipeName,  List<Quantity> perServingQuantities,  int servings)?  $default,) {final _that = this;
switch (_that) {
case _IngredientSource() when $default != null:
return $default(_that.recipeName,_that.perServingQuantities,_that.servings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IngredientSource implements IngredientSource {
  const _IngredientSource({required this.recipeName, final  List<Quantity> perServingQuantities = const [], required this.servings}): _perServingQuantities = perServingQuantities;
  factory _IngredientSource.fromJson(Map<String, dynamic> json) => _$IngredientSourceFromJson(json);

@override final  String recipeName;
 final  List<Quantity> _perServingQuantities;
@override@JsonKey() List<Quantity> get perServingQuantities {
  if (_perServingQuantities is EqualUnmodifiableListView) return _perServingQuantities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_perServingQuantities);
}

@override final  int servings;

/// Create a copy of IngredientSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngredientSourceCopyWith<_IngredientSource> get copyWith => __$IngredientSourceCopyWithImpl<_IngredientSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IngredientSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngredientSource&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&const DeepCollectionEquality().equals(other._perServingQuantities, _perServingQuantities)&&(identical(other.servings, servings) || other.servings == servings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipeName,const DeepCollectionEquality().hash(_perServingQuantities),servings);

@override
String toString() {
  return 'IngredientSource(recipeName: $recipeName, perServingQuantities: $perServingQuantities, servings: $servings)';
}


}

/// @nodoc
abstract mixin class _$IngredientSourceCopyWith<$Res> implements $IngredientSourceCopyWith<$Res> {
  factory _$IngredientSourceCopyWith(_IngredientSource value, $Res Function(_IngredientSource) _then) = __$IngredientSourceCopyWithImpl;
@override @useResult
$Res call({
 String recipeName, List<Quantity> perServingQuantities, int servings
});




}
/// @nodoc
class __$IngredientSourceCopyWithImpl<$Res>
    implements _$IngredientSourceCopyWith<$Res> {
  __$IngredientSourceCopyWithImpl(this._self, this._then);

  final _IngredientSource _self;
  final $Res Function(_IngredientSource) _then;

/// Create a copy of IngredientSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipeName = null,Object? perServingQuantities = null,Object? servings = null,}) {
  return _then(_IngredientSource(
recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,perServingQuantities: null == perServingQuantities ? _self._perServingQuantities : perServingQuantities // ignore: cast_nullable_to_non_nullable
as List<Quantity>,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
