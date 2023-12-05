// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Step _$StepFromJson(Map<String, dynamic> json) {
  return _Step.fromJson(json);
}

/// @nodoc
mixin _$Step {
  List<IngredientUsage> get ingredientUsage =>
      throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StepCopyWith<Step> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StepCopyWith<$Res> {
  factory $StepCopyWith(Step value, $Res Function(Step) then) =
      _$StepCopyWithImpl<$Res, Step>;
  @useResult
  $Res call({List<IngredientUsage> ingredientUsage, String description});
}

/// @nodoc
class _$StepCopyWithImpl<$Res, $Val extends Step>
    implements $StepCopyWith<$Res> {
  _$StepCopyWithImpl(this._value, this._then);

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
abstract class _$$StepImplCopyWith<$Res> implements $StepCopyWith<$Res> {
  factory _$$StepImplCopyWith(
          _$StepImpl value, $Res Function(_$StepImpl) then) =
      __$$StepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<IngredientUsage> ingredientUsage, String description});
}

/// @nodoc
class __$$StepImplCopyWithImpl<$Res>
    extends _$StepCopyWithImpl<$Res, _$StepImpl>
    implements _$$StepImplCopyWith<$Res> {
  __$$StepImplCopyWithImpl(_$StepImpl _value, $Res Function(_$StepImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ingredientUsage = null,
    Object? description = null,
  }) {
    return _then(_$StepImpl(
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
class _$StepImpl with DiagnosticableTreeMixin implements _Step {
  const _$StepImpl(
      {required final List<IngredientUsage> ingredientUsage,
      required this.description})
      : _ingredientUsage = ingredientUsage;

  factory _$StepImpl.fromJson(Map<String, dynamic> json) =>
      _$$StepImplFromJson(json);

  final List<IngredientUsage> _ingredientUsage;
  @override
  List<IngredientUsage> get ingredientUsage {
    if (_ingredientUsage is EqualUnmodifiableListView) return _ingredientUsage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredientUsage);
  }

  @override
  final String description;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Step(ingredientUsage: $ingredientUsage, description: $description)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Step'))
      ..add(DiagnosticsProperty('ingredientUsage', ingredientUsage))
      ..add(DiagnosticsProperty('description', description));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StepImpl &&
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
  _$$StepImplCopyWith<_$StepImpl> get copyWith =>
      __$$StepImplCopyWithImpl<_$StepImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StepImplToJson(
      this,
    );
  }
}

abstract class _Step implements Step {
  const factory _Step(
      {required final List<IngredientUsage> ingredientUsage,
      required final String description}) = _$StepImpl;

  factory _Step.fromJson(Map<String, dynamic> json) = _$StepImpl.fromJson;

  @override
  List<IngredientUsage> get ingredientUsage;
  @override
  String get description;
  @override
  @JsonKey(ignore: true)
  _$$StepImplCopyWith<_$StepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
