// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_pdf_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MenuPdfDish {

 String get recipeName; int get people; MenuPdfDishSource get source;/// The servings that the cook makes at this meal, from `MultiWeekMenu.servingsForCookEvent`.
/// It counts the later leftover meals too, so it is above [people] whenever the menu reuses
/// the dish. It is 0 for every source but [MenuPdfDishSource.cooked].
 int get servingsToCook;
/// Create a copy of MenuPdfDish
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuPdfDishCopyWith<MenuPdfDish> get copyWith => _$MenuPdfDishCopyWithImpl<MenuPdfDish>(this as MenuPdfDish, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuPdfDish&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.people, people) || other.people == people)&&(identical(other.source, source) || other.source == source)&&(identical(other.servingsToCook, servingsToCook) || other.servingsToCook == servingsToCook));
}


@override
int get hashCode => Object.hash(runtimeType,recipeName,people,source,servingsToCook);

@override
String toString() {
  return 'MenuPdfDish(recipeName: $recipeName, people: $people, source: $source, servingsToCook: $servingsToCook)';
}


}

/// @nodoc
abstract mixin class $MenuPdfDishCopyWith<$Res>  {
  factory $MenuPdfDishCopyWith(MenuPdfDish value, $Res Function(MenuPdfDish) _then) = _$MenuPdfDishCopyWithImpl;
@useResult
$Res call({
 String recipeName, int people, MenuPdfDishSource source, int servingsToCook
});




}
/// @nodoc
class _$MenuPdfDishCopyWithImpl<$Res>
    implements $MenuPdfDishCopyWith<$Res> {
  _$MenuPdfDishCopyWithImpl(this._self, this._then);

  final MenuPdfDish _self;
  final $Res Function(MenuPdfDish) _then;

/// Create a copy of MenuPdfDish
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipeName = null,Object? people = null,Object? source = null,Object? servingsToCook = null,}) {
  return _then(_self.copyWith(
recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MenuPdfDishSource,servingsToCook: null == servingsToCook ? _self.servingsToCook : servingsToCook // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuPdfDish].
extension MenuPdfDishPatterns on MenuPdfDish {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuPdfDish value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuPdfDish() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuPdfDish value)  $default,){
final _that = this;
switch (_that) {
case _MenuPdfDish():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuPdfDish value)?  $default,){
final _that = this;
switch (_that) {
case _MenuPdfDish() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recipeName,  int people,  MenuPdfDishSource source,  int servingsToCook)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuPdfDish() when $default != null:
return $default(_that.recipeName,_that.people,_that.source,_that.servingsToCook);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recipeName,  int people,  MenuPdfDishSource source,  int servingsToCook)  $default,) {final _that = this;
switch (_that) {
case _MenuPdfDish():
return $default(_that.recipeName,_that.people,_that.source,_that.servingsToCook);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recipeName,  int people,  MenuPdfDishSource source,  int servingsToCook)?  $default,) {final _that = this;
switch (_that) {
case _MenuPdfDish() when $default != null:
return $default(_that.recipeName,_that.people,_that.source,_that.servingsToCook);case _:
  return null;

}
}

}

/// @nodoc


class _MenuPdfDish extends MenuPdfDish {
  const _MenuPdfDish({required this.recipeName, required this.people, required this.source, required this.servingsToCook}): super._();
  

@override final  String recipeName;
@override final  int people;
@override final  MenuPdfDishSource source;
/// The servings that the cook makes at this meal, from `MultiWeekMenu.servingsForCookEvent`.
/// It counts the later leftover meals too, so it is above [people] whenever the menu reuses
/// the dish. It is 0 for every source but [MenuPdfDishSource.cooked].
@override final  int servingsToCook;

/// Create a copy of MenuPdfDish
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuPdfDishCopyWith<_MenuPdfDish> get copyWith => __$MenuPdfDishCopyWithImpl<_MenuPdfDish>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuPdfDish&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.people, people) || other.people == people)&&(identical(other.source, source) || other.source == source)&&(identical(other.servingsToCook, servingsToCook) || other.servingsToCook == servingsToCook));
}


@override
int get hashCode => Object.hash(runtimeType,recipeName,people,source,servingsToCook);

@override
String toString() {
  return 'MenuPdfDish(recipeName: $recipeName, people: $people, source: $source, servingsToCook: $servingsToCook)';
}


}

/// @nodoc
abstract mixin class _$MenuPdfDishCopyWith<$Res> implements $MenuPdfDishCopyWith<$Res> {
  factory _$MenuPdfDishCopyWith(_MenuPdfDish value, $Res Function(_MenuPdfDish) _then) = __$MenuPdfDishCopyWithImpl;
@override @useResult
$Res call({
 String recipeName, int people, MenuPdfDishSource source, int servingsToCook
});




}
/// @nodoc
class __$MenuPdfDishCopyWithImpl<$Res>
    implements _$MenuPdfDishCopyWith<$Res> {
  __$MenuPdfDishCopyWithImpl(this._self, this._then);

  final _MenuPdfDish _self;
  final $Res Function(_MenuPdfDish) _then;

/// Create a copy of MenuPdfDish
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipeName = null,Object? people = null,Object? source = null,Object? servingsToCook = null,}) {
  return _then(_MenuPdfDish(
recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MenuPdfDishSource,servingsToCook: null == servingsToCook ? _self.servingsToCook : servingsToCook // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$MenuPdfSlot {

 MealType get mealType; List<MenuPdfDish> get dishes;
/// Create a copy of MenuPdfSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuPdfSlotCopyWith<MenuPdfSlot> get copyWith => _$MenuPdfSlotCopyWithImpl<MenuPdfSlot>(this as MenuPdfSlot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuPdfSlot&&(identical(other.mealType, mealType) || other.mealType == mealType)&&const DeepCollectionEquality().equals(other.dishes, dishes));
}


@override
int get hashCode => Object.hash(runtimeType,mealType,const DeepCollectionEquality().hash(dishes));

@override
String toString() {
  return 'MenuPdfSlot(mealType: $mealType, dishes: $dishes)';
}


}

/// @nodoc
abstract mixin class $MenuPdfSlotCopyWith<$Res>  {
  factory $MenuPdfSlotCopyWith(MenuPdfSlot value, $Res Function(MenuPdfSlot) _then) = _$MenuPdfSlotCopyWithImpl;
@useResult
$Res call({
 MealType mealType, List<MenuPdfDish> dishes
});




}
/// @nodoc
class _$MenuPdfSlotCopyWithImpl<$Res>
    implements $MenuPdfSlotCopyWith<$Res> {
  _$MenuPdfSlotCopyWithImpl(this._self, this._then);

  final MenuPdfSlot _self;
  final $Res Function(MenuPdfSlot) _then;

/// Create a copy of MenuPdfSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mealType = null,Object? dishes = null,}) {
  return _then(_self.copyWith(
mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,dishes: null == dishes ? _self.dishes : dishes // ignore: cast_nullable_to_non_nullable
as List<MenuPdfDish>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuPdfSlot].
extension MenuPdfSlotPatterns on MenuPdfSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuPdfSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuPdfSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuPdfSlot value)  $default,){
final _that = this;
switch (_that) {
case _MenuPdfSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuPdfSlot value)?  $default,){
final _that = this;
switch (_that) {
case _MenuPdfSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MealType mealType,  List<MenuPdfDish> dishes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuPdfSlot() when $default != null:
return $default(_that.mealType,_that.dishes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MealType mealType,  List<MenuPdfDish> dishes)  $default,) {final _that = this;
switch (_that) {
case _MenuPdfSlot():
return $default(_that.mealType,_that.dishes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MealType mealType,  List<MenuPdfDish> dishes)?  $default,) {final _that = this;
switch (_that) {
case _MenuPdfSlot() when $default != null:
return $default(_that.mealType,_that.dishes);case _:
  return null;

}
}

}

/// @nodoc


class _MenuPdfSlot implements MenuPdfSlot {
  const _MenuPdfSlot({required this.mealType, final  List<MenuPdfDish> dishes = const []}): _dishes = dishes;
  

@override final  MealType mealType;
 final  List<MenuPdfDish> _dishes;
@override@JsonKey() List<MenuPdfDish> get dishes {
  if (_dishes is EqualUnmodifiableListView) return _dishes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dishes);
}


/// Create a copy of MenuPdfSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuPdfSlotCopyWith<_MenuPdfSlot> get copyWith => __$MenuPdfSlotCopyWithImpl<_MenuPdfSlot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuPdfSlot&&(identical(other.mealType, mealType) || other.mealType == mealType)&&const DeepCollectionEquality().equals(other._dishes, _dishes));
}


@override
int get hashCode => Object.hash(runtimeType,mealType,const DeepCollectionEquality().hash(_dishes));

@override
String toString() {
  return 'MenuPdfSlot(mealType: $mealType, dishes: $dishes)';
}


}

/// @nodoc
abstract mixin class _$MenuPdfSlotCopyWith<$Res> implements $MenuPdfSlotCopyWith<$Res> {
  factory _$MenuPdfSlotCopyWith(_MenuPdfSlot value, $Res Function(_MenuPdfSlot) _then) = __$MenuPdfSlotCopyWithImpl;
@override @useResult
$Res call({
 MealType mealType, List<MenuPdfDish> dishes
});




}
/// @nodoc
class __$MenuPdfSlotCopyWithImpl<$Res>
    implements _$MenuPdfSlotCopyWith<$Res> {
  __$MenuPdfSlotCopyWithImpl(this._self, this._then);

  final _MenuPdfSlot _self;
  final $Res Function(_MenuPdfSlot) _then;

/// Create a copy of MenuPdfSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mealType = null,Object? dishes = null,}) {
  return _then(_MenuPdfSlot(
mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,dishes: null == dishes ? _self._dishes : dishes // ignore: cast_nullable_to_non_nullable
as List<MenuPdfDish>,
  ));
}


}

/// @nodoc
mixin _$MenuPdfDayRow {

 String get dayLabel; List<MenuPdfSlot> get slots;
/// Create a copy of MenuPdfDayRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuPdfDayRowCopyWith<MenuPdfDayRow> get copyWith => _$MenuPdfDayRowCopyWithImpl<MenuPdfDayRow>(this as MenuPdfDayRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuPdfDayRow&&(identical(other.dayLabel, dayLabel) || other.dayLabel == dayLabel)&&const DeepCollectionEquality().equals(other.slots, slots));
}


@override
int get hashCode => Object.hash(runtimeType,dayLabel,const DeepCollectionEquality().hash(slots));

@override
String toString() {
  return 'MenuPdfDayRow(dayLabel: $dayLabel, slots: $slots)';
}


}

/// @nodoc
abstract mixin class $MenuPdfDayRowCopyWith<$Res>  {
  factory $MenuPdfDayRowCopyWith(MenuPdfDayRow value, $Res Function(MenuPdfDayRow) _then) = _$MenuPdfDayRowCopyWithImpl;
@useResult
$Res call({
 String dayLabel, List<MenuPdfSlot> slots
});




}
/// @nodoc
class _$MenuPdfDayRowCopyWithImpl<$Res>
    implements $MenuPdfDayRowCopyWith<$Res> {
  _$MenuPdfDayRowCopyWithImpl(this._self, this._then);

  final MenuPdfDayRow _self;
  final $Res Function(MenuPdfDayRow) _then;

/// Create a copy of MenuPdfDayRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dayLabel = null,Object? slots = null,}) {
  return _then(_self.copyWith(
dayLabel: null == dayLabel ? _self.dayLabel : dayLabel // ignore: cast_nullable_to_non_nullable
as String,slots: null == slots ? _self.slots : slots // ignore: cast_nullable_to_non_nullable
as List<MenuPdfSlot>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuPdfDayRow].
extension MenuPdfDayRowPatterns on MenuPdfDayRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuPdfDayRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuPdfDayRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuPdfDayRow value)  $default,){
final _that = this;
switch (_that) {
case _MenuPdfDayRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuPdfDayRow value)?  $default,){
final _that = this;
switch (_that) {
case _MenuPdfDayRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String dayLabel,  List<MenuPdfSlot> slots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuPdfDayRow() when $default != null:
return $default(_that.dayLabel,_that.slots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String dayLabel,  List<MenuPdfSlot> slots)  $default,) {final _that = this;
switch (_that) {
case _MenuPdfDayRow():
return $default(_that.dayLabel,_that.slots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String dayLabel,  List<MenuPdfSlot> slots)?  $default,) {final _that = this;
switch (_that) {
case _MenuPdfDayRow() when $default != null:
return $default(_that.dayLabel,_that.slots);case _:
  return null;

}
}

}

/// @nodoc


class _MenuPdfDayRow implements MenuPdfDayRow {
  const _MenuPdfDayRow({required this.dayLabel, final  List<MenuPdfSlot> slots = const []}): _slots = slots;
  

@override final  String dayLabel;
 final  List<MenuPdfSlot> _slots;
@override@JsonKey() List<MenuPdfSlot> get slots {
  if (_slots is EqualUnmodifiableListView) return _slots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_slots);
}


/// Create a copy of MenuPdfDayRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuPdfDayRowCopyWith<_MenuPdfDayRow> get copyWith => __$MenuPdfDayRowCopyWithImpl<_MenuPdfDayRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuPdfDayRow&&(identical(other.dayLabel, dayLabel) || other.dayLabel == dayLabel)&&const DeepCollectionEquality().equals(other._slots, _slots));
}


@override
int get hashCode => Object.hash(runtimeType,dayLabel,const DeepCollectionEquality().hash(_slots));

@override
String toString() {
  return 'MenuPdfDayRow(dayLabel: $dayLabel, slots: $slots)';
}


}

/// @nodoc
abstract mixin class _$MenuPdfDayRowCopyWith<$Res> implements $MenuPdfDayRowCopyWith<$Res> {
  factory _$MenuPdfDayRowCopyWith(_MenuPdfDayRow value, $Res Function(_MenuPdfDayRow) _then) = __$MenuPdfDayRowCopyWithImpl;
@override @useResult
$Res call({
 String dayLabel, List<MenuPdfSlot> slots
});




}
/// @nodoc
class __$MenuPdfDayRowCopyWithImpl<$Res>
    implements _$MenuPdfDayRowCopyWith<$Res> {
  __$MenuPdfDayRowCopyWithImpl(this._self, this._then);

  final _MenuPdfDayRow _self;
  final $Res Function(_MenuPdfDayRow) _then;

/// Create a copy of MenuPdfDayRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dayLabel = null,Object? slots = null,}) {
  return _then(_MenuPdfDayRow(
dayLabel: null == dayLabel ? _self.dayLabel : dayLabel // ignore: cast_nullable_to_non_nullable
as String,slots: null == slots ? _self._slots : slots // ignore: cast_nullable_to_non_nullable
as List<MenuPdfSlot>,
  ));
}


}

/// @nodoc
mixin _$MenuPdfWeekSection {

 String get title; List<MenuPdfDayRow> get days;
/// Create a copy of MenuPdfWeekSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuPdfWeekSectionCopyWith<MenuPdfWeekSection> get copyWith => _$MenuPdfWeekSectionCopyWithImpl<MenuPdfWeekSection>(this as MenuPdfWeekSection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuPdfWeekSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.days, days));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(days));

@override
String toString() {
  return 'MenuPdfWeekSection(title: $title, days: $days)';
}


}

/// @nodoc
abstract mixin class $MenuPdfWeekSectionCopyWith<$Res>  {
  factory $MenuPdfWeekSectionCopyWith(MenuPdfWeekSection value, $Res Function(MenuPdfWeekSection) _then) = _$MenuPdfWeekSectionCopyWithImpl;
@useResult
$Res call({
 String title, List<MenuPdfDayRow> days
});




}
/// @nodoc
class _$MenuPdfWeekSectionCopyWithImpl<$Res>
    implements $MenuPdfWeekSectionCopyWith<$Res> {
  _$MenuPdfWeekSectionCopyWithImpl(this._self, this._then);

  final MenuPdfWeekSection _self;
  final $Res Function(MenuPdfWeekSection) _then;

/// Create a copy of MenuPdfWeekSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? days = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<MenuPdfDayRow>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuPdfWeekSection].
extension MenuPdfWeekSectionPatterns on MenuPdfWeekSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuPdfWeekSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuPdfWeekSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuPdfWeekSection value)  $default,){
final _that = this;
switch (_that) {
case _MenuPdfWeekSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuPdfWeekSection value)?  $default,){
final _that = this;
switch (_that) {
case _MenuPdfWeekSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<MenuPdfDayRow> days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuPdfWeekSection() when $default != null:
return $default(_that.title,_that.days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<MenuPdfDayRow> days)  $default,) {final _that = this;
switch (_that) {
case _MenuPdfWeekSection():
return $default(_that.title,_that.days);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<MenuPdfDayRow> days)?  $default,) {final _that = this;
switch (_that) {
case _MenuPdfWeekSection() when $default != null:
return $default(_that.title,_that.days);case _:
  return null;

}
}

}

/// @nodoc


class _MenuPdfWeekSection implements MenuPdfWeekSection {
  const _MenuPdfWeekSection({required this.title, final  List<MenuPdfDayRow> days = const []}): _days = days;
  

@override final  String title;
 final  List<MenuPdfDayRow> _days;
@override@JsonKey() List<MenuPdfDayRow> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}


/// Create a copy of MenuPdfWeekSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuPdfWeekSectionCopyWith<_MenuPdfWeekSection> get copyWith => __$MenuPdfWeekSectionCopyWithImpl<_MenuPdfWeekSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuPdfWeekSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._days, _days));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_days));

@override
String toString() {
  return 'MenuPdfWeekSection(title: $title, days: $days)';
}


}

/// @nodoc
abstract mixin class _$MenuPdfWeekSectionCopyWith<$Res> implements $MenuPdfWeekSectionCopyWith<$Res> {
  factory _$MenuPdfWeekSectionCopyWith(_MenuPdfWeekSection value, $Res Function(_MenuPdfWeekSection) _then) = __$MenuPdfWeekSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, List<MenuPdfDayRow> days
});




}
/// @nodoc
class __$MenuPdfWeekSectionCopyWithImpl<$Res>
    implements _$MenuPdfWeekSectionCopyWith<$Res> {
  __$MenuPdfWeekSectionCopyWithImpl(this._self, this._then);

  final _MenuPdfWeekSection _self;
  final $Res Function(_MenuPdfWeekSection) _then;

/// Create a copy of MenuPdfWeekSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? days = null,}) {
  return _then(_MenuPdfWeekSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<MenuPdfDayRow>,
  ));
}


}

/// @nodoc
mixin _$MenuPdfIngredientLine {

 String get ingredientName; String get amounts;
/// Create a copy of MenuPdfIngredientLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuPdfIngredientLineCopyWith<MenuPdfIngredientLine> get copyWith => _$MenuPdfIngredientLineCopyWithImpl<MenuPdfIngredientLine>(this as MenuPdfIngredientLine, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuPdfIngredientLine&&(identical(other.ingredientName, ingredientName) || other.ingredientName == ingredientName)&&(identical(other.amounts, amounts) || other.amounts == amounts));
}


@override
int get hashCode => Object.hash(runtimeType,ingredientName,amounts);

@override
String toString() {
  return 'MenuPdfIngredientLine(ingredientName: $ingredientName, amounts: $amounts)';
}


}

/// @nodoc
abstract mixin class $MenuPdfIngredientLineCopyWith<$Res>  {
  factory $MenuPdfIngredientLineCopyWith(MenuPdfIngredientLine value, $Res Function(MenuPdfIngredientLine) _then) = _$MenuPdfIngredientLineCopyWithImpl;
@useResult
$Res call({
 String ingredientName, String amounts
});




}
/// @nodoc
class _$MenuPdfIngredientLineCopyWithImpl<$Res>
    implements $MenuPdfIngredientLineCopyWith<$Res> {
  _$MenuPdfIngredientLineCopyWithImpl(this._self, this._then);

  final MenuPdfIngredientLine _self;
  final $Res Function(MenuPdfIngredientLine) _then;

/// Create a copy of MenuPdfIngredientLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ingredientName = null,Object? amounts = null,}) {
  return _then(_self.copyWith(
ingredientName: null == ingredientName ? _self.ingredientName : ingredientName // ignore: cast_nullable_to_non_nullable
as String,amounts: null == amounts ? _self.amounts : amounts // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuPdfIngredientLine].
extension MenuPdfIngredientLinePatterns on MenuPdfIngredientLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuPdfIngredientLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuPdfIngredientLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuPdfIngredientLine value)  $default,){
final _that = this;
switch (_that) {
case _MenuPdfIngredientLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuPdfIngredientLine value)?  $default,){
final _that = this;
switch (_that) {
case _MenuPdfIngredientLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ingredientName,  String amounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuPdfIngredientLine() when $default != null:
return $default(_that.ingredientName,_that.amounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ingredientName,  String amounts)  $default,) {final _that = this;
switch (_that) {
case _MenuPdfIngredientLine():
return $default(_that.ingredientName,_that.amounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ingredientName,  String amounts)?  $default,) {final _that = this;
switch (_that) {
case _MenuPdfIngredientLine() when $default != null:
return $default(_that.ingredientName,_that.amounts);case _:
  return null;

}
}

}

/// @nodoc


class _MenuPdfIngredientLine implements MenuPdfIngredientLine {
  const _MenuPdfIngredientLine({required this.ingredientName, required this.amounts});
  

@override final  String ingredientName;
@override final  String amounts;

/// Create a copy of MenuPdfIngredientLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuPdfIngredientLineCopyWith<_MenuPdfIngredientLine> get copyWith => __$MenuPdfIngredientLineCopyWithImpl<_MenuPdfIngredientLine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuPdfIngredientLine&&(identical(other.ingredientName, ingredientName) || other.ingredientName == ingredientName)&&(identical(other.amounts, amounts) || other.amounts == amounts));
}


@override
int get hashCode => Object.hash(runtimeType,ingredientName,amounts);

@override
String toString() {
  return 'MenuPdfIngredientLine(ingredientName: $ingredientName, amounts: $amounts)';
}


}

/// @nodoc
abstract mixin class _$MenuPdfIngredientLineCopyWith<$Res> implements $MenuPdfIngredientLineCopyWith<$Res> {
  factory _$MenuPdfIngredientLineCopyWith(_MenuPdfIngredientLine value, $Res Function(_MenuPdfIngredientLine) _then) = __$MenuPdfIngredientLineCopyWithImpl;
@override @useResult
$Res call({
 String ingredientName, String amounts
});




}
/// @nodoc
class __$MenuPdfIngredientLineCopyWithImpl<$Res>
    implements _$MenuPdfIngredientLineCopyWith<$Res> {
  __$MenuPdfIngredientLineCopyWithImpl(this._self, this._then);

  final _MenuPdfIngredientLine _self;
  final $Res Function(_MenuPdfIngredientLine) _then;

/// Create a copy of MenuPdfIngredientLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ingredientName = null,Object? amounts = null,}) {
  return _then(_MenuPdfIngredientLine(
ingredientName: null == ingredientName ? _self.ingredientName : ingredientName // ignore: cast_nullable_to_non_nullable
as String,amounts: null == amounts ? _self.amounts : amounts // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$MenuPdfStep {

 int get number; String get description; int get workingTimeMinutes; int get cookingTimeMinutes; List<MenuPdfIngredientLine> get ingredients;
/// Create a copy of MenuPdfStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuPdfStepCopyWith<MenuPdfStep> get copyWith => _$MenuPdfStepCopyWithImpl<MenuPdfStep>(this as MenuPdfStep, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuPdfStep&&(identical(other.number, number) || other.number == number)&&(identical(other.description, description) || other.description == description)&&(identical(other.workingTimeMinutes, workingTimeMinutes) || other.workingTimeMinutes == workingTimeMinutes)&&(identical(other.cookingTimeMinutes, cookingTimeMinutes) || other.cookingTimeMinutes == cookingTimeMinutes)&&const DeepCollectionEquality().equals(other.ingredients, ingredients));
}


@override
int get hashCode => Object.hash(runtimeType,number,description,workingTimeMinutes,cookingTimeMinutes,const DeepCollectionEquality().hash(ingredients));

@override
String toString() {
  return 'MenuPdfStep(number: $number, description: $description, workingTimeMinutes: $workingTimeMinutes, cookingTimeMinutes: $cookingTimeMinutes, ingredients: $ingredients)';
}


}

/// @nodoc
abstract mixin class $MenuPdfStepCopyWith<$Res>  {
  factory $MenuPdfStepCopyWith(MenuPdfStep value, $Res Function(MenuPdfStep) _then) = _$MenuPdfStepCopyWithImpl;
@useResult
$Res call({
 int number, String description, int workingTimeMinutes, int cookingTimeMinutes, List<MenuPdfIngredientLine> ingredients
});




}
/// @nodoc
class _$MenuPdfStepCopyWithImpl<$Res>
    implements $MenuPdfStepCopyWith<$Res> {
  _$MenuPdfStepCopyWithImpl(this._self, this._then);

  final MenuPdfStep _self;
  final $Res Function(MenuPdfStep) _then;

/// Create a copy of MenuPdfStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? description = null,Object? workingTimeMinutes = null,Object? cookingTimeMinutes = null,Object? ingredients = null,}) {
  return _then(_self.copyWith(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,workingTimeMinutes: null == workingTimeMinutes ? _self.workingTimeMinutes : workingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,cookingTimeMinutes: null == cookingTimeMinutes ? _self.cookingTimeMinutes : cookingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<MenuPdfIngredientLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuPdfStep].
extension MenuPdfStepPatterns on MenuPdfStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuPdfStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuPdfStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuPdfStep value)  $default,){
final _that = this;
switch (_that) {
case _MenuPdfStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuPdfStep value)?  $default,){
final _that = this;
switch (_that) {
case _MenuPdfStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int number,  String description,  int workingTimeMinutes,  int cookingTimeMinutes,  List<MenuPdfIngredientLine> ingredients)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuPdfStep() when $default != null:
return $default(_that.number,_that.description,_that.workingTimeMinutes,_that.cookingTimeMinutes,_that.ingredients);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int number,  String description,  int workingTimeMinutes,  int cookingTimeMinutes,  List<MenuPdfIngredientLine> ingredients)  $default,) {final _that = this;
switch (_that) {
case _MenuPdfStep():
return $default(_that.number,_that.description,_that.workingTimeMinutes,_that.cookingTimeMinutes,_that.ingredients);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int number,  String description,  int workingTimeMinutes,  int cookingTimeMinutes,  List<MenuPdfIngredientLine> ingredients)?  $default,) {final _that = this;
switch (_that) {
case _MenuPdfStep() when $default != null:
return $default(_that.number,_that.description,_that.workingTimeMinutes,_that.cookingTimeMinutes,_that.ingredients);case _:
  return null;

}
}

}

/// @nodoc


class _MenuPdfStep implements MenuPdfStep {
  const _MenuPdfStep({required this.number, required this.description, required this.workingTimeMinutes, required this.cookingTimeMinutes, final  List<MenuPdfIngredientLine> ingredients = const []}): _ingredients = ingredients;
  

@override final  int number;
@override final  String description;
@override final  int workingTimeMinutes;
@override final  int cookingTimeMinutes;
 final  List<MenuPdfIngredientLine> _ingredients;
@override@JsonKey() List<MenuPdfIngredientLine> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}


/// Create a copy of MenuPdfStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuPdfStepCopyWith<_MenuPdfStep> get copyWith => __$MenuPdfStepCopyWithImpl<_MenuPdfStep>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuPdfStep&&(identical(other.number, number) || other.number == number)&&(identical(other.description, description) || other.description == description)&&(identical(other.workingTimeMinutes, workingTimeMinutes) || other.workingTimeMinutes == workingTimeMinutes)&&(identical(other.cookingTimeMinutes, cookingTimeMinutes) || other.cookingTimeMinutes == cookingTimeMinutes)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients));
}


@override
int get hashCode => Object.hash(runtimeType,number,description,workingTimeMinutes,cookingTimeMinutes,const DeepCollectionEquality().hash(_ingredients));

@override
String toString() {
  return 'MenuPdfStep(number: $number, description: $description, workingTimeMinutes: $workingTimeMinutes, cookingTimeMinutes: $cookingTimeMinutes, ingredients: $ingredients)';
}


}

/// @nodoc
abstract mixin class _$MenuPdfStepCopyWith<$Res> implements $MenuPdfStepCopyWith<$Res> {
  factory _$MenuPdfStepCopyWith(_MenuPdfStep value, $Res Function(_MenuPdfStep) _then) = __$MenuPdfStepCopyWithImpl;
@override @useResult
$Res call({
 int number, String description, int workingTimeMinutes, int cookingTimeMinutes, List<MenuPdfIngredientLine> ingredients
});




}
/// @nodoc
class __$MenuPdfStepCopyWithImpl<$Res>
    implements _$MenuPdfStepCopyWith<$Res> {
  __$MenuPdfStepCopyWithImpl(this._self, this._then);

  final _MenuPdfStep _self;
  final $Res Function(_MenuPdfStep) _then;

/// Create a copy of MenuPdfStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? description = null,Object? workingTimeMinutes = null,Object? cookingTimeMinutes = null,Object? ingredients = null,}) {
  return _then(_MenuPdfStep(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,workingTimeMinutes: null == workingTimeMinutes ? _self.workingTimeMinutes : workingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,cookingTimeMinutes: null == cookingTimeMinutes ? _self.cookingTimeMinutes : cookingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<MenuPdfIngredientLine>,
  ));
}


}

/// @nodoc
mixin _$MenuPdfRecipeSection {

 String get recipeName; int get servings; int get workingTimeMinutes; int get cookingTimeMinutes; List<MenuPdfIngredientLine> get ingredients; List<MenuPdfStep> get steps;
/// Create a copy of MenuPdfRecipeSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuPdfRecipeSectionCopyWith<MenuPdfRecipeSection> get copyWith => _$MenuPdfRecipeSectionCopyWithImpl<MenuPdfRecipeSection>(this as MenuPdfRecipeSection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuPdfRecipeSection&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.workingTimeMinutes, workingTimeMinutes) || other.workingTimeMinutes == workingTimeMinutes)&&(identical(other.cookingTimeMinutes, cookingTimeMinutes) || other.cookingTimeMinutes == cookingTimeMinutes)&&const DeepCollectionEquality().equals(other.ingredients, ingredients)&&const DeepCollectionEquality().equals(other.steps, steps));
}


@override
int get hashCode => Object.hash(runtimeType,recipeName,servings,workingTimeMinutes,cookingTimeMinutes,const DeepCollectionEquality().hash(ingredients),const DeepCollectionEquality().hash(steps));

@override
String toString() {
  return 'MenuPdfRecipeSection(recipeName: $recipeName, servings: $servings, workingTimeMinutes: $workingTimeMinutes, cookingTimeMinutes: $cookingTimeMinutes, ingredients: $ingredients, steps: $steps)';
}


}

/// @nodoc
abstract mixin class $MenuPdfRecipeSectionCopyWith<$Res>  {
  factory $MenuPdfRecipeSectionCopyWith(MenuPdfRecipeSection value, $Res Function(MenuPdfRecipeSection) _then) = _$MenuPdfRecipeSectionCopyWithImpl;
@useResult
$Res call({
 String recipeName, int servings, int workingTimeMinutes, int cookingTimeMinutes, List<MenuPdfIngredientLine> ingredients, List<MenuPdfStep> steps
});




}
/// @nodoc
class _$MenuPdfRecipeSectionCopyWithImpl<$Res>
    implements $MenuPdfRecipeSectionCopyWith<$Res> {
  _$MenuPdfRecipeSectionCopyWithImpl(this._self, this._then);

  final MenuPdfRecipeSection _self;
  final $Res Function(MenuPdfRecipeSection) _then;

/// Create a copy of MenuPdfRecipeSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipeName = null,Object? servings = null,Object? workingTimeMinutes = null,Object? cookingTimeMinutes = null,Object? ingredients = null,Object? steps = null,}) {
  return _then(_self.copyWith(
recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,workingTimeMinutes: null == workingTimeMinutes ? _self.workingTimeMinutes : workingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,cookingTimeMinutes: null == cookingTimeMinutes ? _self.cookingTimeMinutes : cookingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<MenuPdfIngredientLine>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<MenuPdfStep>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuPdfRecipeSection].
extension MenuPdfRecipeSectionPatterns on MenuPdfRecipeSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuPdfRecipeSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuPdfRecipeSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuPdfRecipeSection value)  $default,){
final _that = this;
switch (_that) {
case _MenuPdfRecipeSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuPdfRecipeSection value)?  $default,){
final _that = this;
switch (_that) {
case _MenuPdfRecipeSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recipeName,  int servings,  int workingTimeMinutes,  int cookingTimeMinutes,  List<MenuPdfIngredientLine> ingredients,  List<MenuPdfStep> steps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuPdfRecipeSection() when $default != null:
return $default(_that.recipeName,_that.servings,_that.workingTimeMinutes,_that.cookingTimeMinutes,_that.ingredients,_that.steps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recipeName,  int servings,  int workingTimeMinutes,  int cookingTimeMinutes,  List<MenuPdfIngredientLine> ingredients,  List<MenuPdfStep> steps)  $default,) {final _that = this;
switch (_that) {
case _MenuPdfRecipeSection():
return $default(_that.recipeName,_that.servings,_that.workingTimeMinutes,_that.cookingTimeMinutes,_that.ingredients,_that.steps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recipeName,  int servings,  int workingTimeMinutes,  int cookingTimeMinutes,  List<MenuPdfIngredientLine> ingredients,  List<MenuPdfStep> steps)?  $default,) {final _that = this;
switch (_that) {
case _MenuPdfRecipeSection() when $default != null:
return $default(_that.recipeName,_that.servings,_that.workingTimeMinutes,_that.cookingTimeMinutes,_that.ingredients,_that.steps);case _:
  return null;

}
}

}

/// @nodoc


class _MenuPdfRecipeSection extends MenuPdfRecipeSection {
  const _MenuPdfRecipeSection({required this.recipeName, required this.servings, required this.workingTimeMinutes, required this.cookingTimeMinutes, final  List<MenuPdfIngredientLine> ingredients = const [], final  List<MenuPdfStep> steps = const []}): _ingredients = ingredients,_steps = steps,super._();
  

@override final  String recipeName;
@override final  int servings;
@override final  int workingTimeMinutes;
@override final  int cookingTimeMinutes;
 final  List<MenuPdfIngredientLine> _ingredients;
@override@JsonKey() List<MenuPdfIngredientLine> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

 final  List<MenuPdfStep> _steps;
@override@JsonKey() List<MenuPdfStep> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}


/// Create a copy of MenuPdfRecipeSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuPdfRecipeSectionCopyWith<_MenuPdfRecipeSection> get copyWith => __$MenuPdfRecipeSectionCopyWithImpl<_MenuPdfRecipeSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuPdfRecipeSection&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.workingTimeMinutes, workingTimeMinutes) || other.workingTimeMinutes == workingTimeMinutes)&&(identical(other.cookingTimeMinutes, cookingTimeMinutes) || other.cookingTimeMinutes == cookingTimeMinutes)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients)&&const DeepCollectionEquality().equals(other._steps, _steps));
}


@override
int get hashCode => Object.hash(runtimeType,recipeName,servings,workingTimeMinutes,cookingTimeMinutes,const DeepCollectionEquality().hash(_ingredients),const DeepCollectionEquality().hash(_steps));

@override
String toString() {
  return 'MenuPdfRecipeSection(recipeName: $recipeName, servings: $servings, workingTimeMinutes: $workingTimeMinutes, cookingTimeMinutes: $cookingTimeMinutes, ingredients: $ingredients, steps: $steps)';
}


}

/// @nodoc
abstract mixin class _$MenuPdfRecipeSectionCopyWith<$Res> implements $MenuPdfRecipeSectionCopyWith<$Res> {
  factory _$MenuPdfRecipeSectionCopyWith(_MenuPdfRecipeSection value, $Res Function(_MenuPdfRecipeSection) _then) = __$MenuPdfRecipeSectionCopyWithImpl;
@override @useResult
$Res call({
 String recipeName, int servings, int workingTimeMinutes, int cookingTimeMinutes, List<MenuPdfIngredientLine> ingredients, List<MenuPdfStep> steps
});




}
/// @nodoc
class __$MenuPdfRecipeSectionCopyWithImpl<$Res>
    implements _$MenuPdfRecipeSectionCopyWith<$Res> {
  __$MenuPdfRecipeSectionCopyWithImpl(this._self, this._then);

  final _MenuPdfRecipeSection _self;
  final $Res Function(_MenuPdfRecipeSection) _then;

/// Create a copy of MenuPdfRecipeSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipeName = null,Object? servings = null,Object? workingTimeMinutes = null,Object? cookingTimeMinutes = null,Object? ingredients = null,Object? steps = null,}) {
  return _then(_MenuPdfRecipeSection(
recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as int,workingTimeMinutes: null == workingTimeMinutes ? _self.workingTimeMinutes : workingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,cookingTimeMinutes: null == cookingTimeMinutes ? _self.cookingTimeMinutes : cookingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<MenuPdfIngredientLine>,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<MenuPdfStep>,
  ));
}


}

/// @nodoc
mixin _$MenuPdfDocument {

 String get title; List<MenuPdfWeekSection> get weeks; List<MenuPdfRecipeSection> get recipes;
/// Create a copy of MenuPdfDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuPdfDocumentCopyWith<MenuPdfDocument> get copyWith => _$MenuPdfDocumentCopyWithImpl<MenuPdfDocument>(this as MenuPdfDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuPdfDocument&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.weeks, weeks)&&const DeepCollectionEquality().equals(other.recipes, recipes));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(weeks),const DeepCollectionEquality().hash(recipes));

@override
String toString() {
  return 'MenuPdfDocument(title: $title, weeks: $weeks, recipes: $recipes)';
}


}

/// @nodoc
abstract mixin class $MenuPdfDocumentCopyWith<$Res>  {
  factory $MenuPdfDocumentCopyWith(MenuPdfDocument value, $Res Function(MenuPdfDocument) _then) = _$MenuPdfDocumentCopyWithImpl;
@useResult
$Res call({
 String title, List<MenuPdfWeekSection> weeks, List<MenuPdfRecipeSection> recipes
});




}
/// @nodoc
class _$MenuPdfDocumentCopyWithImpl<$Res>
    implements $MenuPdfDocumentCopyWith<$Res> {
  _$MenuPdfDocumentCopyWithImpl(this._self, this._then);

  final MenuPdfDocument _self;
  final $Res Function(MenuPdfDocument) _then;

/// Create a copy of MenuPdfDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? weeks = null,Object? recipes = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,weeks: null == weeks ? _self.weeks : weeks // ignore: cast_nullable_to_non_nullable
as List<MenuPdfWeekSection>,recipes: null == recipes ? _self.recipes : recipes // ignore: cast_nullable_to_non_nullable
as List<MenuPdfRecipeSection>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuPdfDocument].
extension MenuPdfDocumentPatterns on MenuPdfDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuPdfDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuPdfDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuPdfDocument value)  $default,){
final _that = this;
switch (_that) {
case _MenuPdfDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuPdfDocument value)?  $default,){
final _that = this;
switch (_that) {
case _MenuPdfDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<MenuPdfWeekSection> weeks,  List<MenuPdfRecipeSection> recipes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuPdfDocument() when $default != null:
return $default(_that.title,_that.weeks,_that.recipes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<MenuPdfWeekSection> weeks,  List<MenuPdfRecipeSection> recipes)  $default,) {final _that = this;
switch (_that) {
case _MenuPdfDocument():
return $default(_that.title,_that.weeks,_that.recipes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<MenuPdfWeekSection> weeks,  List<MenuPdfRecipeSection> recipes)?  $default,) {final _that = this;
switch (_that) {
case _MenuPdfDocument() when $default != null:
return $default(_that.title,_that.weeks,_that.recipes);case _:
  return null;

}
}

}

/// @nodoc


class _MenuPdfDocument implements MenuPdfDocument {
  const _MenuPdfDocument({required this.title, final  List<MenuPdfWeekSection> weeks = const [], final  List<MenuPdfRecipeSection> recipes = const []}): _weeks = weeks,_recipes = recipes;
  

@override final  String title;
 final  List<MenuPdfWeekSection> _weeks;
@override@JsonKey() List<MenuPdfWeekSection> get weeks {
  if (_weeks is EqualUnmodifiableListView) return _weeks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeks);
}

 final  List<MenuPdfRecipeSection> _recipes;
@override@JsonKey() List<MenuPdfRecipeSection> get recipes {
  if (_recipes is EqualUnmodifiableListView) return _recipes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recipes);
}


/// Create a copy of MenuPdfDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuPdfDocumentCopyWith<_MenuPdfDocument> get copyWith => __$MenuPdfDocumentCopyWithImpl<_MenuPdfDocument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuPdfDocument&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._weeks, _weeks)&&const DeepCollectionEquality().equals(other._recipes, _recipes));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_weeks),const DeepCollectionEquality().hash(_recipes));

@override
String toString() {
  return 'MenuPdfDocument(title: $title, weeks: $weeks, recipes: $recipes)';
}


}

/// @nodoc
abstract mixin class _$MenuPdfDocumentCopyWith<$Res> implements $MenuPdfDocumentCopyWith<$Res> {
  factory _$MenuPdfDocumentCopyWith(_MenuPdfDocument value, $Res Function(_MenuPdfDocument) _then) = __$MenuPdfDocumentCopyWithImpl;
@override @useResult
$Res call({
 String title, List<MenuPdfWeekSection> weeks, List<MenuPdfRecipeSection> recipes
});




}
/// @nodoc
class __$MenuPdfDocumentCopyWithImpl<$Res>
    implements _$MenuPdfDocumentCopyWith<$Res> {
  __$MenuPdfDocumentCopyWithImpl(this._self, this._then);

  final _MenuPdfDocument _self;
  final $Res Function(_MenuPdfDocument) _then;

/// Create a copy of MenuPdfDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? weeks = null,Object? recipes = null,}) {
  return _then(_MenuPdfDocument(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,weeks: null == weeks ? _self._weeks : weeks // ignore: cast_nullable_to_non_nullable
as List<MenuPdfWeekSection>,recipes: null == recipes ? _self._recipes : recipes // ignore: cast_nullable_to_non_nullable
as List<MenuPdfRecipeSection>,
  ));
}


}

// dart format on
