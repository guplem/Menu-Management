// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Recipe _$RecipeFromJson(Map<String, dynamic> json) {
  return _Recipe.fromJson(json);
}

/// @nodoc
mixin _$Recipe {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<Instruction> get instructions => throw _privateConstructorUsedError;
  bool get carbs => throw _privateConstructorUsedError;
  bool get proteins => throw _privateConstructorUsedError;
  bool get vegetables => throw _privateConstructorUsedError;
  RecipeType? get type => throw _privateConstructorUsedError;

  /// The number of days the recipe can be stored in the fridge (coocked)
  int get maxStorageDays => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecipeCopyWith<Recipe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeCopyWith<$Res> {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) then) =
      _$RecipeCopyWithImpl<$Res, Recipe>;
  @useResult
  $Res call(
      {String id,
      String name,
      List<Instruction> instructions,
      bool carbs,
      bool proteins,
      bool vegetables,
      RecipeType? type,
      int maxStorageDays});
}

/// @nodoc
class _$RecipeCopyWithImpl<$Res, $Val extends Recipe>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? instructions = null,
    Object? carbs = null,
    Object? proteins = null,
    Object? vegetables = null,
    Object? type = freezed,
    Object? maxStorageDays = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<Instruction>,
      carbs: null == carbs
          ? _value.carbs
          : carbs // ignore: cast_nullable_to_non_nullable
              as bool,
      proteins: null == proteins
          ? _value.proteins
          : proteins // ignore: cast_nullable_to_non_nullable
              as bool,
      vegetables: null == vegetables
          ? _value.vegetables
          : vegetables // ignore: cast_nullable_to_non_nullable
              as bool,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecipeType?,
      maxStorageDays: null == maxStorageDays
          ? _value.maxStorageDays
          : maxStorageDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecipeImplCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$$RecipeImplCopyWith(
          _$RecipeImpl value, $Res Function(_$RecipeImpl) then) =
      __$$RecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      List<Instruction> instructions,
      bool carbs,
      bool proteins,
      bool vegetables,
      RecipeType? type,
      int maxStorageDays});
}

/// @nodoc
class __$$RecipeImplCopyWithImpl<$Res>
    extends _$RecipeCopyWithImpl<$Res, _$RecipeImpl>
    implements _$$RecipeImplCopyWith<$Res> {
  __$$RecipeImplCopyWithImpl(
      _$RecipeImpl _value, $Res Function(_$RecipeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? instructions = null,
    Object? carbs = null,
    Object? proteins = null,
    Object? vegetables = null,
    Object? type = freezed,
    Object? maxStorageDays = null,
  }) {
    return _then(_$RecipeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      instructions: null == instructions
          ? _value._instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<Instruction>,
      carbs: null == carbs
          ? _value.carbs
          : carbs // ignore: cast_nullable_to_non_nullable
              as bool,
      proteins: null == proteins
          ? _value.proteins
          : proteins // ignore: cast_nullable_to_non_nullable
              as bool,
      vegetables: null == vegetables
          ? _value.vegetables
          : vegetables // ignore: cast_nullable_to_non_nullable
              as bool,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecipeType?,
      maxStorageDays: null == maxStorageDays
          ? _value.maxStorageDays
          : maxStorageDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeImpl extends _Recipe with DiagnosticableTreeMixin {
  const _$RecipeImpl(
      {required this.id,
      required this.name,
      final List<Instruction> instructions = const [],
      this.carbs = false,
      this.proteins = false,
      this.vegetables = false,
      this.type,
      this.maxStorageDays = 7})
      : _instructions = instructions,
        super._();

  factory _$RecipeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<Instruction> _instructions;
  @override
  @JsonKey()
  List<Instruction> get instructions {
    if (_instructions is EqualUnmodifiableListView) return _instructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_instructions);
  }

  @override
  @JsonKey()
  final bool carbs;
  @override
  @JsonKey()
  final bool proteins;
  @override
  @JsonKey()
  final bool vegetables;
  @override
  final RecipeType? type;

  /// The number of days the recipe can be stored in the fridge (coocked)
  @override
  @JsonKey()
  final int maxStorageDays;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Recipe(id: $id, name: $name, instructions: $instructions, carbs: $carbs, proteins: $proteins, vegetables: $vegetables, type: $type, maxStorageDays: $maxStorageDays)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Recipe'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('instructions', instructions))
      ..add(DiagnosticsProperty('carbs', carbs))
      ..add(DiagnosticsProperty('proteins', proteins))
      ..add(DiagnosticsProperty('vegetables', vegetables))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('maxStorageDays', maxStorageDays));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._instructions, _instructions) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.proteins, proteins) ||
                other.proteins == proteins) &&
            (identical(other.vegetables, vegetables) ||
                other.vegetables == vegetables) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.maxStorageDays, maxStorageDays) ||
                other.maxStorageDays == maxStorageDays));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_instructions),
      carbs,
      proteins,
      vegetables,
      type,
      maxStorageDays);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      __$$RecipeImplCopyWithImpl<_$RecipeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeImplToJson(
      this,
    );
  }
}

abstract class _Recipe extends Recipe {
  const factory _Recipe(
      {required final String id,
      required final String name,
      final List<Instruction> instructions,
      final bool carbs,
      final bool proteins,
      final bool vegetables,
      final RecipeType? type,
      final int maxStorageDays}) = _$RecipeImpl;
  const _Recipe._() : super._();

  factory _Recipe.fromJson(Map<String, dynamic> json) = _$RecipeImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<Instruction> get instructions;
  @override
  bool get carbs;
  @override
  bool get proteins;
  @override
  bool get vegetables;
  @override
  RecipeType? get type;
  @override

  /// The number of days the recipe can be stored in the fridge (coocked)
  int get maxStorageDays;
  @override
  @JsonKey(ignore: true)
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
