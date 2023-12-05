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
  List<IngredientUsage> get ingredientUsage =>
      throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

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
  $Res call({List<IngredientUsage> ingredientUsage, String description});
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
    Object? ingredientUsage = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      ingredientUsage: null == ingredientUsage
          ? _value.ingredientUsage
          : ingredientUsage // ignore: cast_nullable_to_non_nullable
              as List<IngredientUsage>,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
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
  $Res call({List<IngredientUsage> ingredientUsage, String description});
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
    Object? ingredientUsage = null,
    Object? description = null,
  }) {
    return _then(_$InstructionImpl(
      ingredientUsage: null == ingredientUsage
          ? _value._ingredientUsage
          : ingredientUsage // ignore: cast_nullable_to_non_nullable
              as List<IngredientUsage>,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InstructionImpl with DiagnosticableTreeMixin implements _Instruction {
  const _$InstructionImpl(
      {final List<IngredientUsage> ingredientUsage = const [],
      required this.description})
      : _ingredientUsage = ingredientUsage;

  factory _$InstructionImpl.fromJson(Map<String, dynamic> json) =>
      _$$InstructionImplFromJson(json);

  final List<IngredientUsage> _ingredientUsage;
  @override
  @JsonKey()
  List<IngredientUsage> get ingredientUsage {
    if (_ingredientUsage is EqualUnmodifiableListView) return _ingredientUsage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredientUsage);
  }

  @override
  final String description;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Instruction(ingredientUsage: $ingredientUsage, description: $description)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Instruction'))
      ..add(DiagnosticsProperty('ingredientUsage', ingredientUsage))
      ..add(DiagnosticsProperty('description', description));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InstructionImpl &&
            const DeepCollectionEquality()
                .equals(other._ingredientUsage, _ingredientUsage) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_ingredientUsage), description);

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

abstract class _Instruction implements Instruction {
  const factory _Instruction(
      {final List<IngredientUsage> ingredientUsage,
      required final String description}) = _$InstructionImpl;

  factory _Instruction.fromJson(Map<String, dynamic> json) =
      _$InstructionImpl.fromJson;

  @override
  List<IngredientUsage> get ingredientUsage;
  @override
  String get description;
  @override
  @JsonKey(ignore: true)
  _$$InstructionImplCopyWith<_$InstructionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
