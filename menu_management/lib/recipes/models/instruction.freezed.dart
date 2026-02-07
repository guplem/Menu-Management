// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instruction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Instruction {

 String get id; List<IngredientUsage> get ingredientsUsed; int get workingTimeMinutes; int get cookingTimeMinutes; String get description; List<Result> get outputs; List<String> get inputs;
/// Create a copy of Instruction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InstructionCopyWith<Instruction> get copyWith => _$InstructionCopyWithImpl<Instruction>(this as Instruction, _$identity);

  /// Serializes this Instruction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Instruction&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.ingredientsUsed, ingredientsUsed)&&(identical(other.workingTimeMinutes, workingTimeMinutes) || other.workingTimeMinutes == workingTimeMinutes)&&(identical(other.cookingTimeMinutes, cookingTimeMinutes) || other.cookingTimeMinutes == cookingTimeMinutes)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.outputs, outputs)&&const DeepCollectionEquality().equals(other.inputs, inputs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(ingredientsUsed),workingTimeMinutes,cookingTimeMinutes,description,const DeepCollectionEquality().hash(outputs),const DeepCollectionEquality().hash(inputs));

@override
String toString() {
  return 'Instruction(id: $id, ingredientsUsed: $ingredientsUsed, workingTimeMinutes: $workingTimeMinutes, cookingTimeMinutes: $cookingTimeMinutes, description: $description, outputs: $outputs, inputs: $inputs)';
}


}

/// @nodoc
abstract mixin class $InstructionCopyWith<$Res>  {
  factory $InstructionCopyWith(Instruction value, $Res Function(Instruction) _then) = _$InstructionCopyWithImpl;
@useResult
$Res call({
 String id, List<IngredientUsage> ingredientsUsed, int workingTimeMinutes, int cookingTimeMinutes, String description, List<Result> outputs, List<String> inputs
});




}
/// @nodoc
class _$InstructionCopyWithImpl<$Res>
    implements $InstructionCopyWith<$Res> {
  _$InstructionCopyWithImpl(this._self, this._then);

  final Instruction _self;
  final $Res Function(Instruction) _then;

/// Create a copy of Instruction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ingredientsUsed = null,Object? workingTimeMinutes = null,Object? cookingTimeMinutes = null,Object? description = null,Object? outputs = null,Object? inputs = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ingredientsUsed: null == ingredientsUsed ? _self.ingredientsUsed : ingredientsUsed // ignore: cast_nullable_to_non_nullable
as List<IngredientUsage>,workingTimeMinutes: null == workingTimeMinutes ? _self.workingTimeMinutes : workingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,cookingTimeMinutes: null == cookingTimeMinutes ? _self.cookingTimeMinutes : cookingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,outputs: null == outputs ? _self.outputs : outputs // ignore: cast_nullable_to_non_nullable
as List<Result>,inputs: null == inputs ? _self.inputs : inputs // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Instruction].
extension InstructionPatterns on Instruction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Instruction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Instruction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Instruction value)  $default,){
final _that = this;
switch (_that) {
case _Instruction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Instruction value)?  $default,){
final _that = this;
switch (_that) {
case _Instruction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<IngredientUsage> ingredientsUsed,  int workingTimeMinutes,  int cookingTimeMinutes,  String description,  List<Result> outputs,  List<String> inputs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Instruction() when $default != null:
return $default(_that.id,_that.ingredientsUsed,_that.workingTimeMinutes,_that.cookingTimeMinutes,_that.description,_that.outputs,_that.inputs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<IngredientUsage> ingredientsUsed,  int workingTimeMinutes,  int cookingTimeMinutes,  String description,  List<Result> outputs,  List<String> inputs)  $default,) {final _that = this;
switch (_that) {
case _Instruction():
return $default(_that.id,_that.ingredientsUsed,_that.workingTimeMinutes,_that.cookingTimeMinutes,_that.description,_that.outputs,_that.inputs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<IngredientUsage> ingredientsUsed,  int workingTimeMinutes,  int cookingTimeMinutes,  String description,  List<Result> outputs,  List<String> inputs)?  $default,) {final _that = this;
switch (_that) {
case _Instruction() when $default != null:
return $default(_that.id,_that.ingredientsUsed,_that.workingTimeMinutes,_that.cookingTimeMinutes,_that.description,_that.outputs,_that.inputs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Instruction extends Instruction {
  const _Instruction({required this.id, final  List<IngredientUsage> ingredientsUsed = const [], this.workingTimeMinutes = 10, this.cookingTimeMinutes = 10, required this.description, final  List<Result> outputs = const [], final  List<String> inputs = const []}): _ingredientsUsed = ingredientsUsed,_outputs = outputs,_inputs = inputs,super._();
  factory _Instruction.fromJson(Map<String, dynamic> json) => _$InstructionFromJson(json);

@override final  String id;
 final  List<IngredientUsage> _ingredientsUsed;
@override@JsonKey() List<IngredientUsage> get ingredientsUsed {
  if (_ingredientsUsed is EqualUnmodifiableListView) return _ingredientsUsed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredientsUsed);
}

@override@JsonKey() final  int workingTimeMinutes;
@override@JsonKey() final  int cookingTimeMinutes;
@override final  String description;
 final  List<Result> _outputs;
@override@JsonKey() List<Result> get outputs {
  if (_outputs is EqualUnmodifiableListView) return _outputs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_outputs);
}

 final  List<String> _inputs;
@override@JsonKey() List<String> get inputs {
  if (_inputs is EqualUnmodifiableListView) return _inputs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inputs);
}


/// Create a copy of Instruction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InstructionCopyWith<_Instruction> get copyWith => __$InstructionCopyWithImpl<_Instruction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InstructionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Instruction&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._ingredientsUsed, _ingredientsUsed)&&(identical(other.workingTimeMinutes, workingTimeMinutes) || other.workingTimeMinutes == workingTimeMinutes)&&(identical(other.cookingTimeMinutes, cookingTimeMinutes) || other.cookingTimeMinutes == cookingTimeMinutes)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._outputs, _outputs)&&const DeepCollectionEquality().equals(other._inputs, _inputs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_ingredientsUsed),workingTimeMinutes,cookingTimeMinutes,description,const DeepCollectionEquality().hash(_outputs),const DeepCollectionEquality().hash(_inputs));

@override
String toString() {
  return 'Instruction(id: $id, ingredientsUsed: $ingredientsUsed, workingTimeMinutes: $workingTimeMinutes, cookingTimeMinutes: $cookingTimeMinutes, description: $description, outputs: $outputs, inputs: $inputs)';
}


}

/// @nodoc
abstract mixin class _$InstructionCopyWith<$Res> implements $InstructionCopyWith<$Res> {
  factory _$InstructionCopyWith(_Instruction value, $Res Function(_Instruction) _then) = __$InstructionCopyWithImpl;
@override @useResult
$Res call({
 String id, List<IngredientUsage> ingredientsUsed, int workingTimeMinutes, int cookingTimeMinutes, String description, List<Result> outputs, List<String> inputs
});




}
/// @nodoc
class __$InstructionCopyWithImpl<$Res>
    implements _$InstructionCopyWith<$Res> {
  __$InstructionCopyWithImpl(this._self, this._then);

  final _Instruction _self;
  final $Res Function(_Instruction) _then;

/// Create a copy of Instruction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ingredientsUsed = null,Object? workingTimeMinutes = null,Object? cookingTimeMinutes = null,Object? description = null,Object? outputs = null,Object? inputs = null,}) {
  return _then(_Instruction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ingredientsUsed: null == ingredientsUsed ? _self._ingredientsUsed : ingredientsUsed // ignore: cast_nullable_to_non_nullable
as List<IngredientUsage>,workingTimeMinutes: null == workingTimeMinutes ? _self.workingTimeMinutes : workingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,cookingTimeMinutes: null == cookingTimeMinutes ? _self.cookingTimeMinutes : cookingTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,outputs: null == outputs ? _self._outputs : outputs // ignore: cast_nullable_to_non_nullable
as List<Result>,inputs: null == inputs ? _self._inputs : inputs // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
