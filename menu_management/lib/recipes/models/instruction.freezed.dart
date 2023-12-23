// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'instruction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Instruction _$InstructionFromJson(Map<String, dynamic> json) {
  return _Instruction.fromJson(json);
}

/// @nodoc
mixin _$Instruction {
  String get id => throw _privateConstructorUsedError;
  List<IngredientUsage> get ingredientsUsed =>
      throw _privateConstructorUsedError;
  int get workingTimeMinutes => throw _privateConstructorUsedError;
  int get cookingTimeMinutes => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<Result> get outputs => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InstructionCopyWith<Instruction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InstructionCopyWith<$Res> {
  factory $InstructionCopyWith(
          Instruction value, $Res Function(Instruction) then) =
      _$InstructionCopyWithImpl<$Res, Instruction>;
  @useResult
  $Res call(
      {String id,
      List<IngredientUsage> ingredientsUsed,
      int workingTimeMinutes,
      int cookingTimeMinutes,
      String description,
      List<Result> outputs});
}

/// @nodoc
class _$InstructionCopyWithImpl<$Res, $Val extends Instruction>
    implements $InstructionCopyWith<$Res> {
  _$InstructionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientsUsed = null,
    Object? workingTimeMinutes = null,
    Object? cookingTimeMinutes = null,
    Object? description = null,
    Object? outputs = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ingredientsUsed: null == ingredientsUsed
          ? _value.ingredientsUsed
          : ingredientsUsed // ignore: cast_nullable_to_non_nullable
              as List<IngredientUsage>,
      workingTimeMinutes: null == workingTimeMinutes
          ? _value.workingTimeMinutes
          : workingTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      cookingTimeMinutes: null == cookingTimeMinutes
          ? _value.cookingTimeMinutes
          : cookingTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      outputs: null == outputs
          ? _value.outputs
          : outputs // ignore: cast_nullable_to_non_nullable
              as List<Result>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InstructionImplCopyWith<$Res>
    implements $InstructionCopyWith<$Res> {
  factory _$$InstructionImplCopyWith(
          _$InstructionImpl value, $Res Function(_$InstructionImpl) then) =
      __$$InstructionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<IngredientUsage> ingredientsUsed,
      int workingTimeMinutes,
      int cookingTimeMinutes,
      String description,
      List<Result> outputs});
}

/// @nodoc
class __$$InstructionImplCopyWithImpl<$Res>
    extends _$InstructionCopyWithImpl<$Res, _$InstructionImpl>
    implements _$$InstructionImplCopyWith<$Res> {
  __$$InstructionImplCopyWithImpl(
      _$InstructionImpl _value, $Res Function(_$InstructionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ingredientsUsed = null,
    Object? workingTimeMinutes = null,
    Object? cookingTimeMinutes = null,
    Object? description = null,
    Object? outputs = null,
  }) {
    return _then(_$InstructionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ingredientsUsed: null == ingredientsUsed
          ? _value._ingredientsUsed
          : ingredientsUsed // ignore: cast_nullable_to_non_nullable
              as List<IngredientUsage>,
      workingTimeMinutes: null == workingTimeMinutes
          ? _value.workingTimeMinutes
          : workingTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      cookingTimeMinutes: null == cookingTimeMinutes
          ? _value.cookingTimeMinutes
          : cookingTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      outputs: null == outputs
          ? _value._outputs
          : outputs // ignore: cast_nullable_to_non_nullable
              as List<Result>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InstructionImpl extends _Instruction with DiagnosticableTreeMixin {
  const _$InstructionImpl(
      {required this.id,
      final List<IngredientUsage> ingredientsUsed = const [],
      this.workingTimeMinutes = 10,
      this.cookingTimeMinutes = 10,
      required this.description,
      final List<Result> outputs = const []})
      : _ingredientsUsed = ingredientsUsed,
        _outputs = outputs,
        super._();

  factory _$InstructionImpl.fromJson(Map<String, dynamic> json) =>
      _$$InstructionImplFromJson(json);

  @override
  final String id;
  final List<IngredientUsage> _ingredientsUsed;
  @override
  @JsonKey()
  List<IngredientUsage> get ingredientsUsed {
    if (_ingredientsUsed is EqualUnmodifiableListView) return _ingredientsUsed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredientsUsed);
  }

  @override
  @JsonKey()
  final int workingTimeMinutes;
  @override
  @JsonKey()
  final int cookingTimeMinutes;
  @override
  final String description;
  final List<Result> _outputs;
  @override
  @JsonKey()
  List<Result> get outputs {
    if (_outputs is EqualUnmodifiableListView) return _outputs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_outputs);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Instruction(id: $id, ingredientsUsed: $ingredientsUsed, workingTimeMinutes: $workingTimeMinutes, cookingTimeMinutes: $cookingTimeMinutes, description: $description, outputs: $outputs)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Instruction'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('ingredientsUsed', ingredientsUsed))
      ..add(DiagnosticsProperty('workingTimeMinutes', workingTimeMinutes))
      ..add(DiagnosticsProperty('cookingTimeMinutes', cookingTimeMinutes))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('outputs', outputs));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InstructionImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._ingredientsUsed, _ingredientsUsed) &&
            (identical(other.workingTimeMinutes, workingTimeMinutes) ||
                other.workingTimeMinutes == workingTimeMinutes) &&
            (identical(other.cookingTimeMinutes, cookingTimeMinutes) ||
                other.cookingTimeMinutes == cookingTimeMinutes) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._outputs, _outputs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_ingredientsUsed),
      workingTimeMinutes,
      cookingTimeMinutes,
      description,
      const DeepCollectionEquality().hash(_outputs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InstructionImplCopyWith<_$InstructionImpl> get copyWith =>
      __$$InstructionImplCopyWithImpl<_$InstructionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InstructionImplToJson(
      this,
    );
  }
}

abstract class _Instruction extends Instruction {
  const factory _Instruction(
      {required final String id,
      final List<IngredientUsage> ingredientsUsed,
      final int workingTimeMinutes,
      final int cookingTimeMinutes,
      required final String description,
      final List<Result> outputs}) = _$InstructionImpl;
  const _Instruction._() : super._();

  factory _Instruction.fromJson(Map<String, dynamic> json) =
      _$InstructionImpl.fromJson;

  @override
  String get id;
  @override
  List<IngredientUsage> get ingredientsUsed;
  @override
  int get workingTimeMinutes;
  @override
  int get cookingTimeMinutes;
  @override
  String get description;
  @override
  List<Result> get outputs;
  @override
  @JsonKey(ignore: true)
  _$$InstructionImplCopyWith<_$InstructionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
