// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_meal_requirement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IngredientMealRequirement {

 int get weekIndex; MealTime get mealTime; int get subMealIndex; String get recipeId; String get recipeName; int get people; bool get isCookEvent; List<Quantity> get quantities;
/// Create a copy of IngredientMealRequirement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientMealRequirementCopyWith<IngredientMealRequirement> get copyWith => _$IngredientMealRequirementCopyWithImpl<IngredientMealRequirement>(this as IngredientMealRequirement, _$identity);

  /// Serializes this IngredientMealRequirement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngredientMealRequirement&&(identical(other.weekIndex, weekIndex) || other.weekIndex == weekIndex)&&(identical(other.mealTime, mealTime) || other.mealTime == mealTime)&&(identical(other.subMealIndex, subMealIndex) || other.subMealIndex == subMealIndex)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.people, people) || other.people == people)&&(identical(other.isCookEvent, isCookEvent) || other.isCookEvent == isCookEvent)&&const DeepCollectionEquality().equals(other.quantities, quantities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekIndex,mealTime,subMealIndex,recipeId,recipeName,people,isCookEvent,const DeepCollectionEquality().hash(quantities));

@override
String toString() {
  return 'IngredientMealRequirement(weekIndex: $weekIndex, mealTime: $mealTime, subMealIndex: $subMealIndex, recipeId: $recipeId, recipeName: $recipeName, people: $people, isCookEvent: $isCookEvent, quantities: $quantities)';
}


}

/// @nodoc
abstract mixin class $IngredientMealRequirementCopyWith<$Res>  {
  factory $IngredientMealRequirementCopyWith(IngredientMealRequirement value, $Res Function(IngredientMealRequirement) _then) = _$IngredientMealRequirementCopyWithImpl;
@useResult
$Res call({
 int weekIndex, MealTime mealTime, int subMealIndex, String recipeId, String recipeName, int people, bool isCookEvent, List<Quantity> quantities
});


$MealTimeCopyWith<$Res> get mealTime;

}
/// @nodoc
class _$IngredientMealRequirementCopyWithImpl<$Res>
    implements $IngredientMealRequirementCopyWith<$Res> {
  _$IngredientMealRequirementCopyWithImpl(this._self, this._then);

  final IngredientMealRequirement _self;
  final $Res Function(IngredientMealRequirement) _then;

/// Create a copy of IngredientMealRequirement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekIndex = null,Object? mealTime = null,Object? subMealIndex = null,Object? recipeId = null,Object? recipeName = null,Object? people = null,Object? isCookEvent = null,Object? quantities = null,}) {
  return _then(_self.copyWith(
weekIndex: null == weekIndex ? _self.weekIndex : weekIndex // ignore: cast_nullable_to_non_nullable
as int,mealTime: null == mealTime ? _self.mealTime : mealTime // ignore: cast_nullable_to_non_nullable
as MealTime,subMealIndex: null == subMealIndex ? _self.subMealIndex : subMealIndex // ignore: cast_nullable_to_non_nullable
as int,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as int,isCookEvent: null == isCookEvent ? _self.isCookEvent : isCookEvent // ignore: cast_nullable_to_non_nullable
as bool,quantities: null == quantities ? _self.quantities : quantities // ignore: cast_nullable_to_non_nullable
as List<Quantity>,
  ));
}
/// Create a copy of IngredientMealRequirement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MealTimeCopyWith<$Res> get mealTime {
  
  return $MealTimeCopyWith<$Res>(_self.mealTime, (value) {
    return _then(_self.copyWith(mealTime: value));
  });
}
}


/// Adds pattern-matching-related methods to [IngredientMealRequirement].
extension IngredientMealRequirementPatterns on IngredientMealRequirement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngredientMealRequirement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngredientMealRequirement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngredientMealRequirement value)  $default,){
final _that = this;
switch (_that) {
case _IngredientMealRequirement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngredientMealRequirement value)?  $default,){
final _that = this;
switch (_that) {
case _IngredientMealRequirement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int weekIndex,  MealTime mealTime,  int subMealIndex,  String recipeId,  String recipeName,  int people,  bool isCookEvent,  List<Quantity> quantities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngredientMealRequirement() when $default != null:
return $default(_that.weekIndex,_that.mealTime,_that.subMealIndex,_that.recipeId,_that.recipeName,_that.people,_that.isCookEvent,_that.quantities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int weekIndex,  MealTime mealTime,  int subMealIndex,  String recipeId,  String recipeName,  int people,  bool isCookEvent,  List<Quantity> quantities)  $default,) {final _that = this;
switch (_that) {
case _IngredientMealRequirement():
return $default(_that.weekIndex,_that.mealTime,_that.subMealIndex,_that.recipeId,_that.recipeName,_that.people,_that.isCookEvent,_that.quantities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int weekIndex,  MealTime mealTime,  int subMealIndex,  String recipeId,  String recipeName,  int people,  bool isCookEvent,  List<Quantity> quantities)?  $default,) {final _that = this;
switch (_that) {
case _IngredientMealRequirement() when $default != null:
return $default(_that.weekIndex,_that.mealTime,_that.subMealIndex,_that.recipeId,_that.recipeName,_that.people,_that.isCookEvent,_that.quantities);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IngredientMealRequirement implements IngredientMealRequirement {
  const _IngredientMealRequirement({required this.weekIndex, required this.mealTime, required this.subMealIndex, required this.recipeId, required this.recipeName, required this.people, required this.isCookEvent, final  List<Quantity> quantities = const []}): _quantities = quantities;
  factory _IngredientMealRequirement.fromJson(Map<String, dynamic> json) => _$IngredientMealRequirementFromJson(json);

@override final  int weekIndex;
@override final  MealTime mealTime;
@override final  int subMealIndex;
@override final  String recipeId;
@override final  String recipeName;
@override final  int people;
@override final  bool isCookEvent;
 final  List<Quantity> _quantities;
@override@JsonKey() List<Quantity> get quantities {
  if (_quantities is EqualUnmodifiableListView) return _quantities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quantities);
}


/// Create a copy of IngredientMealRequirement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngredientMealRequirementCopyWith<_IngredientMealRequirement> get copyWith => __$IngredientMealRequirementCopyWithImpl<_IngredientMealRequirement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IngredientMealRequirementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngredientMealRequirement&&(identical(other.weekIndex, weekIndex) || other.weekIndex == weekIndex)&&(identical(other.mealTime, mealTime) || other.mealTime == mealTime)&&(identical(other.subMealIndex, subMealIndex) || other.subMealIndex == subMealIndex)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.people, people) || other.people == people)&&(identical(other.isCookEvent, isCookEvent) || other.isCookEvent == isCookEvent)&&const DeepCollectionEquality().equals(other._quantities, _quantities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekIndex,mealTime,subMealIndex,recipeId,recipeName,people,isCookEvent,const DeepCollectionEquality().hash(_quantities));

@override
String toString() {
  return 'IngredientMealRequirement(weekIndex: $weekIndex, mealTime: $mealTime, subMealIndex: $subMealIndex, recipeId: $recipeId, recipeName: $recipeName, people: $people, isCookEvent: $isCookEvent, quantities: $quantities)';
}


}

/// @nodoc
abstract mixin class _$IngredientMealRequirementCopyWith<$Res> implements $IngredientMealRequirementCopyWith<$Res> {
  factory _$IngredientMealRequirementCopyWith(_IngredientMealRequirement value, $Res Function(_IngredientMealRequirement) _then) = __$IngredientMealRequirementCopyWithImpl;
@override @useResult
$Res call({
 int weekIndex, MealTime mealTime, int subMealIndex, String recipeId, String recipeName, int people, bool isCookEvent, List<Quantity> quantities
});


@override $MealTimeCopyWith<$Res> get mealTime;

}
/// @nodoc
class __$IngredientMealRequirementCopyWithImpl<$Res>
    implements _$IngredientMealRequirementCopyWith<$Res> {
  __$IngredientMealRequirementCopyWithImpl(this._self, this._then);

  final _IngredientMealRequirement _self;
  final $Res Function(_IngredientMealRequirement) _then;

/// Create a copy of IngredientMealRequirement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekIndex = null,Object? mealTime = null,Object? subMealIndex = null,Object? recipeId = null,Object? recipeName = null,Object? people = null,Object? isCookEvent = null,Object? quantities = null,}) {
  return _then(_IngredientMealRequirement(
weekIndex: null == weekIndex ? _self.weekIndex : weekIndex // ignore: cast_nullable_to_non_nullable
as int,mealTime: null == mealTime ? _self.mealTime : mealTime // ignore: cast_nullable_to_non_nullable
as MealTime,subMealIndex: null == subMealIndex ? _self.subMealIndex : subMealIndex // ignore: cast_nullable_to_non_nullable
as int,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as int,isCookEvent: null == isCookEvent ? _self.isCookEvent : isCookEvent // ignore: cast_nullable_to_non_nullable
as bool,quantities: null == quantities ? _self._quantities : quantities // ignore: cast_nullable_to_non_nullable
as List<Quantity>,
  ));
}

/// Create a copy of IngredientMealRequirement
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
