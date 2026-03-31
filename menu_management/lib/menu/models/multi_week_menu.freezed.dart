// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'multi_week_menu.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MultiWeekMenu {

 List<Menu> get weeks;
/// Create a copy of MultiWeekMenu
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MultiWeekMenuCopyWith<MultiWeekMenu> get copyWith => _$MultiWeekMenuCopyWithImpl<MultiWeekMenu>(this as MultiWeekMenu, _$identity);

  /// Serializes this MultiWeekMenu to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MultiWeekMenu&&const DeepCollectionEquality().equals(other.weeks, weeks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(weeks));

@override
String toString() {
  return 'MultiWeekMenu(weeks: $weeks)';
}


}

/// @nodoc
abstract mixin class $MultiWeekMenuCopyWith<$Res>  {
  factory $MultiWeekMenuCopyWith(MultiWeekMenu value, $Res Function(MultiWeekMenu) _then) = _$MultiWeekMenuCopyWithImpl;
@useResult
$Res call({
 List<Menu> weeks
});




}
/// @nodoc
class _$MultiWeekMenuCopyWithImpl<$Res>
    implements $MultiWeekMenuCopyWith<$Res> {
  _$MultiWeekMenuCopyWithImpl(this._self, this._then);

  final MultiWeekMenu _self;
  final $Res Function(MultiWeekMenu) _then;

/// Create a copy of MultiWeekMenu
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weeks = null,}) {
  return _then(_self.copyWith(
weeks: null == weeks ? _self.weeks : weeks // ignore: cast_nullable_to_non_nullable
as List<Menu>,
  ));
}

}


/// Adds pattern-matching-related methods to [MultiWeekMenu].
extension MultiWeekMenuPatterns on MultiWeekMenu {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MultiWeekMenu value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MultiWeekMenu() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MultiWeekMenu value)  $default,){
final _that = this;
switch (_that) {
case _MultiWeekMenu():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MultiWeekMenu value)?  $default,){
final _that = this;
switch (_that) {
case _MultiWeekMenu() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Menu> weeks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MultiWeekMenu() when $default != null:
return $default(_that.weeks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Menu> weeks)  $default,) {final _that = this;
switch (_that) {
case _MultiWeekMenu():
return $default(_that.weeks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Menu> weeks)?  $default,) {final _that = this;
switch (_that) {
case _MultiWeekMenu() when $default != null:
return $default(_that.weeks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MultiWeekMenu extends MultiWeekMenu {
  const _MultiWeekMenu({final  List<Menu> weeks = const []}): _weeks = weeks,super._();
  factory _MultiWeekMenu.fromJson(Map<String, dynamic> json) => _$MultiWeekMenuFromJson(json);

 final  List<Menu> _weeks;
@override@JsonKey() List<Menu> get weeks {
  if (_weeks is EqualUnmodifiableListView) return _weeks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeks);
}


/// Create a copy of MultiWeekMenu
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MultiWeekMenuCopyWith<_MultiWeekMenu> get copyWith => __$MultiWeekMenuCopyWithImpl<_MultiWeekMenu>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MultiWeekMenuToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MultiWeekMenu&&const DeepCollectionEquality().equals(other._weeks, _weeks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_weeks));

@override
String toString() {
  return 'MultiWeekMenu(weeks: $weeks)';
}


}

/// @nodoc
abstract mixin class _$MultiWeekMenuCopyWith<$Res> implements $MultiWeekMenuCopyWith<$Res> {
  factory _$MultiWeekMenuCopyWith(_MultiWeekMenu value, $Res Function(_MultiWeekMenu) _then) = __$MultiWeekMenuCopyWithImpl;
@override @useResult
$Res call({
 List<Menu> weeks
});




}
/// @nodoc
class __$MultiWeekMenuCopyWithImpl<$Res>
    implements _$MultiWeekMenuCopyWith<$Res> {
  __$MultiWeekMenuCopyWithImpl(this._self, this._then);

  final _MultiWeekMenu _self;
  final $Res Function(_MultiWeekMenu) _then;

/// Create a copy of MultiWeekMenu
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weeks = null,}) {
  return _then(_MultiWeekMenu(
weeks: null == weeks ? _self._weeks : weeks // ignore: cast_nullable_to_non_nullable
as List<Menu>,
  ));
}


}

// dart format on
