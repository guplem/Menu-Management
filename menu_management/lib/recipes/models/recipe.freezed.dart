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
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

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
  RecipeType get type => throw _privateConstructorUsedError;
  bool get lunch => throw _privateConstructorUsedError;
  bool get dinner => throw _privateConstructorUsedError;
  bool get canBeStored => throw _privateConstructorUsedError;
  bool get includeInMenuGeneration => throw _privateConstructorUsedError;

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeCopyWith<Recipe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeCopyWith<$Res> {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) then) =
      _$RecipeCopyWithImpl<$Res, Recipe>;
  @useResult
  $Res call({
    String id,
    String name,
    List<Instruction> instructions,
    bool carbs,
    bool proteins,
    bool vegetables,
    RecipeType type,
    bool lunch,
    bool dinner,
    bool canBeStored,
    bool includeInMenuGeneration,
  });
}

/// @nodoc
class _$RecipeCopyWithImpl<$Res, $Val extends Recipe>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? instructions = null,
    Object? carbs = null,
    Object? proteins = null,
    Object? vegetables = null,
    Object? type = null,
    Object? lunch = null,
    Object? dinner = null,
    Object? canBeStored = null,
    Object? includeInMenuGeneration = null,
  }) {
    return _then(
      _value.copyWith(
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as RecipeType,
            lunch: null == lunch
                ? _value.lunch
                : lunch // ignore: cast_nullable_to_non_nullable
                      as bool,
            dinner: null == dinner
                ? _value.dinner
                : dinner // ignore: cast_nullable_to_non_nullable
                      as bool,
            canBeStored: null == canBeStored
                ? _value.canBeStored
                : canBeStored // ignore: cast_nullable_to_non_nullable
                      as bool,
            includeInMenuGeneration: null == includeInMenuGeneration
                ? _value.includeInMenuGeneration
                : includeInMenuGeneration // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeImplCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$$RecipeImplCopyWith(
    _$RecipeImpl value,
    $Res Function(_$RecipeImpl) then,
  ) = __$$RecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<Instruction> instructions,
    bool carbs,
    bool proteins,
    bool vegetables,
    RecipeType type,
    bool lunch,
    bool dinner,
    bool canBeStored,
    bool includeInMenuGeneration,
  });
}

/// @nodoc
class __$$RecipeImplCopyWithImpl<$Res>
    extends _$RecipeCopyWithImpl<$Res, _$RecipeImpl>
    implements _$$RecipeImplCopyWith<$Res> {
  __$$RecipeImplCopyWithImpl(
    _$RecipeImpl _value,
    $Res Function(_$RecipeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? instructions = null,
    Object? carbs = null,
    Object? proteins = null,
    Object? vegetables = null,
    Object? type = null,
    Object? lunch = null,
    Object? dinner = null,
    Object? canBeStored = null,
    Object? includeInMenuGeneration = null,
  }) {
    return _then(
      _$RecipeImpl(
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
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as RecipeType,
        lunch: null == lunch
            ? _value.lunch
            : lunch // ignore: cast_nullable_to_non_nullable
                  as bool,
        dinner: null == dinner
            ? _value.dinner
            : dinner // ignore: cast_nullable_to_non_nullable
                  as bool,
        canBeStored: null == canBeStored
            ? _value.canBeStored
            : canBeStored // ignore: cast_nullable_to_non_nullable
                  as bool,
        includeInMenuGeneration: null == includeInMenuGeneration
            ? _value.includeInMenuGeneration
            : includeInMenuGeneration // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeImpl extends _Recipe with DiagnosticableTreeMixin {
  const _$RecipeImpl({
    required this.id,
    required this.name,
    final List<Instruction> instructions = const [],
    this.carbs = true,
    this.proteins = true,
    this.vegetables = true,
    this.type = RecipeType.meal,
    this.lunch = true,
    this.dinner = true,
    this.canBeStored = true,
    this.includeInMenuGeneration = true,
  }) : _instructions = instructions,
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
  @JsonKey()
  final RecipeType type;
  @override
  @JsonKey()
  final bool lunch;
  @override
  @JsonKey()
  final bool dinner;
  @override
  @JsonKey()
  final bool canBeStored;
  @override
  @JsonKey()
  final bool includeInMenuGeneration;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Recipe(id: $id, name: $name, instructions: $instructions, carbs: $carbs, proteins: $proteins, vegetables: $vegetables, type: $type, lunch: $lunch, dinner: $dinner, canBeStored: $canBeStored, includeInMenuGeneration: $includeInMenuGeneration)';
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
      ..add(DiagnosticsProperty('lunch', lunch))
      ..add(DiagnosticsProperty('dinner', dinner))
      ..add(DiagnosticsProperty('canBeStored', canBeStored))
      ..add(
        DiagnosticsProperty('includeInMenuGeneration', includeInMenuGeneration),
      );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._instructions,
              _instructions,
            ) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.proteins, proteins) ||
                other.proteins == proteins) &&
            (identical(other.vegetables, vegetables) ||
                other.vegetables == vegetables) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.lunch, lunch) || other.lunch == lunch) &&
            (identical(other.dinner, dinner) || other.dinner == dinner) &&
            (identical(other.canBeStored, canBeStored) ||
                other.canBeStored == canBeStored) &&
            (identical(
                  other.includeInMenuGeneration,
                  includeInMenuGeneration,
                ) ||
                other.includeInMenuGeneration == includeInMenuGeneration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
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
    lunch,
    dinner,
    canBeStored,
    includeInMenuGeneration,
  );

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      __$$RecipeImplCopyWithImpl<_$RecipeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeImplToJson(this);
  }
}

abstract class _Recipe extends Recipe {
  const factory _Recipe({
    required final String id,
    required final String name,
    final List<Instruction> instructions,
    final bool carbs,
    final bool proteins,
    final bool vegetables,
    final RecipeType type,
    final bool lunch,
    final bool dinner,
    final bool canBeStored,
    final bool includeInMenuGeneration,
  }) = _$RecipeImpl;
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
  RecipeType get type;
  @override
  bool get lunch;
  @override
  bool get dinner;
  @override
  bool get canBeStored;
  @override
  bool get includeInMenuGeneration;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
