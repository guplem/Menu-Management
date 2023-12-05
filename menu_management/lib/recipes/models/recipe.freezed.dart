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
  String get name => throw _privateConstructorUsedError;
  List<Step> get steps => throw _privateConstructorUsedError;
  bool get carbs => throw _privateConstructorUsedError;
  bool get proteins => throw _privateConstructorUsedError;
  bool get vegetables => throw _privateConstructorUsedError;

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
      {String name,
      List<Step> steps,
      bool carbs,
      bool proteins,
      bool vegetables});
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
    Object? name = null,
    Object? steps = null,
    Object? carbs = null,
    Object? proteins = null,
    Object? vegetables = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<Step>,
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
      {String name,
      List<Step> steps,
      bool carbs,
      bool proteins,
      bool vegetables});
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
    Object? name = null,
    Object? steps = null,
    Object? carbs = null,
    Object? proteins = null,
    Object? vegetables = null,
  }) {
    return _then(_$RecipeImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      steps: null == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<Step>,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeImpl with DiagnosticableTreeMixin implements _Recipe {
  const _$RecipeImpl(
      {required this.name,
      final List<Step> steps = const [],
      this.carbs = false,
      this.proteins = false,
      this.vegetables = false})
      : _steps = steps;

  factory _$RecipeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeImplFromJson(json);

  @override
  final String name;
  final List<Step> _steps;
  @override
  @JsonKey()
  List<Step> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
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
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Recipe(name: $name, steps: $steps, carbs: $carbs, proteins: $proteins, vegetables: $vegetables)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Recipe'))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('steps', steps))
      ..add(DiagnosticsProperty('carbs', carbs))
      ..add(DiagnosticsProperty('proteins', proteins))
      ..add(DiagnosticsProperty('vegetables', vegetables));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.proteins, proteins) ||
                other.proteins == proteins) &&
            (identical(other.vegetables, vegetables) ||
                other.vegetables == vegetables));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name,
      const DeepCollectionEquality().hash(_steps), carbs, proteins, vegetables);

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

abstract class _Recipe implements Recipe {
  const factory _Recipe(
      {required final String name,
      final List<Step> steps,
      final bool carbs,
      final bool proteins,
      final bool vegetables}) = _$RecipeImpl;

  factory _Recipe.fromJson(Map<String, dynamic> json) = _$RecipeImpl.fromJson;

  @override
  String get name;
  @override
  List<Step> get steps;
  @override
  bool get carbs;
  @override
  bool get proteins;
  @override
  bool get vegetables;
  @override
  @JsonKey(ignore: true)
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
