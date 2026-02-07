// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Recipe {

 String get id; String get name; List<Instruction> get instructions; bool get carbs; bool get proteins; bool get vegetables; RecipeType get type; bool get lunch; bool get dinner; bool get canBeStored; bool get includeInMenuGeneration;
/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeCopyWith<Recipe> get copyWith => _$RecipeCopyWithImpl<Recipe>(this as Recipe, _$identity);

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.instructions, instructions)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.proteins, proteins) || other.proteins == proteins)&&(identical(other.vegetables, vegetables) || other.vegetables == vegetables)&&(identical(other.type, type) || other.type == type)&&(identical(other.lunch, lunch) || other.lunch == lunch)&&(identical(other.dinner, dinner) || other.dinner == dinner)&&(identical(other.canBeStored, canBeStored) || other.canBeStored == canBeStored)&&(identical(other.includeInMenuGeneration, includeInMenuGeneration) || other.includeInMenuGeneration == includeInMenuGeneration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(instructions),carbs,proteins,vegetables,type,lunch,dinner,canBeStored,includeInMenuGeneration);

@override
String toString() {
  return 'Recipe(id: $id, name: $name, instructions: $instructions, carbs: $carbs, proteins: $proteins, vegetables: $vegetables, type: $type, lunch: $lunch, dinner: $dinner, canBeStored: $canBeStored, includeInMenuGeneration: $includeInMenuGeneration)';
}


}

/// @nodoc
abstract mixin class $RecipeCopyWith<$Res>  {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) _then) = _$RecipeCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<Instruction> instructions, bool carbs, bool proteins, bool vegetables, RecipeType type, bool lunch, bool dinner, bool canBeStored, bool includeInMenuGeneration
});




}
/// @nodoc
class _$RecipeCopyWithImpl<$Res>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._self, this._then);

  final Recipe _self;
  final $Res Function(Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? instructions = null,Object? carbs = null,Object? proteins = null,Object? vegetables = null,Object? type = null,Object? lunch = null,Object? dinner = null,Object? canBeStored = null,Object? includeInMenuGeneration = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<Instruction>,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as bool,proteins: null == proteins ? _self.proteins : proteins // ignore: cast_nullable_to_non_nullable
as bool,vegetables: null == vegetables ? _self.vegetables : vegetables // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecipeType,lunch: null == lunch ? _self.lunch : lunch // ignore: cast_nullable_to_non_nullable
as bool,dinner: null == dinner ? _self.dinner : dinner // ignore: cast_nullable_to_non_nullable
as bool,canBeStored: null == canBeStored ? _self.canBeStored : canBeStored // ignore: cast_nullable_to_non_nullable
as bool,includeInMenuGeneration: null == includeInMenuGeneration ? _self.includeInMenuGeneration : includeInMenuGeneration // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Recipe].
extension RecipePatterns on Recipe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recipe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recipe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recipe value)  $default,){
final _that = this;
switch (_that) {
case _Recipe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recipe value)?  $default,){
final _that = this;
switch (_that) {
case _Recipe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<Instruction> instructions,  bool carbs,  bool proteins,  bool vegetables,  RecipeType type,  bool lunch,  bool dinner,  bool canBeStored,  bool includeInMenuGeneration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that.id,_that.name,_that.instructions,_that.carbs,_that.proteins,_that.vegetables,_that.type,_that.lunch,_that.dinner,_that.canBeStored,_that.includeInMenuGeneration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<Instruction> instructions,  bool carbs,  bool proteins,  bool vegetables,  RecipeType type,  bool lunch,  bool dinner,  bool canBeStored,  bool includeInMenuGeneration)  $default,) {final _that = this;
switch (_that) {
case _Recipe():
return $default(_that.id,_that.name,_that.instructions,_that.carbs,_that.proteins,_that.vegetables,_that.type,_that.lunch,_that.dinner,_that.canBeStored,_that.includeInMenuGeneration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<Instruction> instructions,  bool carbs,  bool proteins,  bool vegetables,  RecipeType type,  bool lunch,  bool dinner,  bool canBeStored,  bool includeInMenuGeneration)?  $default,) {final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that.id,_that.name,_that.instructions,_that.carbs,_that.proteins,_that.vegetables,_that.type,_that.lunch,_that.dinner,_that.canBeStored,_that.includeInMenuGeneration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recipe extends Recipe {
  const _Recipe({required this.id, required this.name, final  List<Instruction> instructions = const [], this.carbs = true, this.proteins = true, this.vegetables = true, this.type = RecipeType.meal, this.lunch = true, this.dinner = true, this.canBeStored = true, this.includeInMenuGeneration = true}): _instructions = instructions,super._();
  factory _Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

@override final  String id;
@override final  String name;
 final  List<Instruction> _instructions;
@override@JsonKey() List<Instruction> get instructions {
  if (_instructions is EqualUnmodifiableListView) return _instructions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_instructions);
}

@override@JsonKey() final  bool carbs;
@override@JsonKey() final  bool proteins;
@override@JsonKey() final  bool vegetables;
@override@JsonKey() final  RecipeType type;
@override@JsonKey() final  bool lunch;
@override@JsonKey() final  bool dinner;
@override@JsonKey() final  bool canBeStored;
@override@JsonKey() final  bool includeInMenuGeneration;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeCopyWith<_Recipe> get copyWith => __$RecipeCopyWithImpl<_Recipe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._instructions, _instructions)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.proteins, proteins) || other.proteins == proteins)&&(identical(other.vegetables, vegetables) || other.vegetables == vegetables)&&(identical(other.type, type) || other.type == type)&&(identical(other.lunch, lunch) || other.lunch == lunch)&&(identical(other.dinner, dinner) || other.dinner == dinner)&&(identical(other.canBeStored, canBeStored) || other.canBeStored == canBeStored)&&(identical(other.includeInMenuGeneration, includeInMenuGeneration) || other.includeInMenuGeneration == includeInMenuGeneration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_instructions),carbs,proteins,vegetables,type,lunch,dinner,canBeStored,includeInMenuGeneration);

@override
String toString() {
  return 'Recipe(id: $id, name: $name, instructions: $instructions, carbs: $carbs, proteins: $proteins, vegetables: $vegetables, type: $type, lunch: $lunch, dinner: $dinner, canBeStored: $canBeStored, includeInMenuGeneration: $includeInMenuGeneration)';
}


}

/// @nodoc
abstract mixin class _$RecipeCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$RecipeCopyWith(_Recipe value, $Res Function(_Recipe) _then) = __$RecipeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<Instruction> instructions, bool carbs, bool proteins, bool vegetables, RecipeType type, bool lunch, bool dinner, bool canBeStored, bool includeInMenuGeneration
});




}
/// @nodoc
class __$RecipeCopyWithImpl<$Res>
    implements _$RecipeCopyWith<$Res> {
  __$RecipeCopyWithImpl(this._self, this._then);

  final _Recipe _self;
  final $Res Function(_Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? instructions = null,Object? carbs = null,Object? proteins = null,Object? vegetables = null,Object? type = null,Object? lunch = null,Object? dinner = null,Object? canBeStored = null,Object? includeInMenuGeneration = null,}) {
  return _then(_Recipe(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self._instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<Instruction>,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as bool,proteins: null == proteins ? _self.proteins : proteins // ignore: cast_nullable_to_non_nullable
as bool,vegetables: null == vegetables ? _self.vegetables : vegetables // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecipeType,lunch: null == lunch ? _self.lunch : lunch // ignore: cast_nullable_to_non_nullable
as bool,dinner: null == dinner ? _self.dinner : dinner // ignore: cast_nullable_to_non_nullable
as bool,canBeStored: null == canBeStored ? _self.canBeStored : canBeStored // ignore: cast_nullable_to_non_nullable
as bool,includeInMenuGeneration: null == includeInMenuGeneration ? _self.includeInMenuGeneration : includeInMenuGeneration // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
