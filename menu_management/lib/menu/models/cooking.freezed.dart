// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cooking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Cooking _$CookingFromJson(Map<String, dynamic> json) {
  return _Cooking.fromJson(json);
}

/// @nodoc
mixin _$Cooking {
  Recipe get recipe => throw _privateConstructorUsedError;

  /// The amount of meals to cook. [yield] =~ meals. 0 means it should already be cooked. Total servings = people * [yield]
  int get yield => throw _privateConstructorUsedError;

  /// Serializes this Cooking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Cooking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CookingCopyWith<Cooking> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CookingCopyWith<$Res> {
  factory $CookingCopyWith(Cooking value, $Res Function(Cooking) then) =
      _$CookingCopyWithImpl<$Res, Cooking>;
  @useResult
  $Res call({Recipe recipe, int yield});

  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class _$CookingCopyWithImpl<$Res, $Val extends Cooking>
    implements $CookingCopyWith<$Res> {
  _$CookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Cooking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? recipe = null, Object? yield = null}) {
    return _then(
      _value.copyWith(
            recipe: null == recipe
                ? _value.recipe
                : recipe // ignore: cast_nullable_to_non_nullable
                      as Recipe,
            yield: null == yield
                ? _value.yield
                : yield // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of Cooking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecipeCopyWith<$Res> get recipe {
    return $RecipeCopyWith<$Res>(_value.recipe, (value) {
      return _then(_value.copyWith(recipe: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CookingImplCopyWith<$Res> implements $CookingCopyWith<$Res> {
  factory _$$CookingImplCopyWith(
    _$CookingImpl value,
    $Res Function(_$CookingImpl) then,
  ) = __$$CookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Recipe recipe, int yield});

  @override
  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class __$$CookingImplCopyWithImpl<$Res>
    extends _$CookingCopyWithImpl<$Res, _$CookingImpl>
    implements _$$CookingImplCopyWith<$Res> {
  __$$CookingImplCopyWithImpl(
    _$CookingImpl _value,
    $Res Function(_$CookingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Cooking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? recipe = null, Object? yield = null}) {
    return _then(
      _$CookingImpl(
        recipe: null == recipe
            ? _value.recipe
            : recipe // ignore: cast_nullable_to_non_nullable
                  as Recipe,
        yield: null == yield
            ? _value.yield
            : yield // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CookingImpl with DiagnosticableTreeMixin implements _Cooking {
  const _$CookingImpl({required this.recipe, required this.yield});

  factory _$CookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$CookingImplFromJson(json);

  @override
  final Recipe recipe;

  /// The amount of meals to cook. [yield] =~ meals. 0 means it should already be cooked. Total servings = people * [yield]
  @override
  final int yield;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Cooking(recipe: $recipe, yield: $yield)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Cooking'))
      ..add(DiagnosticsProperty('recipe', recipe))
      ..add(DiagnosticsProperty('yield', yield));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CookingImpl &&
            (identical(other.recipe, recipe) || other.recipe == recipe) &&
            (identical(other.yield, yield) || other.yield == yield));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, recipe, yield);

  /// Create a copy of Cooking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CookingImplCopyWith<_$CookingImpl> get copyWith =>
      __$$CookingImplCopyWithImpl<_$CookingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CookingImplToJson(this);
  }
}

abstract class _Cooking implements Cooking {
  const factory _Cooking({
    required final Recipe recipe,
    required final int yield,
  }) = _$CookingImpl;

  factory _Cooking.fromJson(Map<String, dynamic> json) = _$CookingImpl.fromJson;

  @override
  Recipe get recipe;

  /// The amount of meals to cook. [yield] =~ meals. 0 means it should already be cooked. Total servings = people * [yield]
  @override
  int get yield;

  /// Create a copy of Cooking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CookingImplCopyWith<_$CookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
