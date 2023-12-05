// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

IngredientUsage _$IngredientUsageFromJson(Map<String, dynamic> json) {
  return _IngredientUsage.fromJson(json);
}

/// @nodoc
mixin _$IngredientUsage {
  Ingredient get ingredient => throw _privateConstructorUsedError;
  Quantity get quantity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IngredientUsageCopyWith<IngredientUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientUsageCopyWith<$Res> {
  factory $IngredientUsageCopyWith(
          IngredientUsage value, $Res Function(IngredientUsage) then) =
      _$IngredientUsageCopyWithImpl<$Res, IngredientUsage>;
  @useResult
  $Res call({Ingredient ingredient, Quantity quantity});

  $IngredientCopyWith<$Res> get ingredient;
  $QuantityCopyWith<$Res> get quantity;
}

/// @nodoc
class _$IngredientUsageCopyWithImpl<$Res, $Val extends IngredientUsage>
    implements $IngredientUsageCopyWith<$Res> {
  _$IngredientUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ingredient = null,
    Object? quantity = null,
  }) {
    return _then(_value.copyWith(
      ingredient: null == ingredient
          ? _value.ingredient
          : ingredient // ignore: cast_nullable_to_non_nullable
              as Ingredient,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as Quantity,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $IngredientCopyWith<$Res> get ingredient {
    return $IngredientCopyWith<$Res>(_value.ingredient, (value) {
      return _then(_value.copyWith(ingredient: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $QuantityCopyWith<$Res> get quantity {
    return $QuantityCopyWith<$Res>(_value.quantity, (value) {
      return _then(_value.copyWith(quantity: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$IngredientUsageImplCopyWith<$Res>
    implements $IngredientUsageCopyWith<$Res> {
  factory _$$IngredientUsageImplCopyWith(_$IngredientUsageImpl value,
          $Res Function(_$IngredientUsageImpl) then) =
      __$$IngredientUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Ingredient ingredient, Quantity quantity});

  @override
  $IngredientCopyWith<$Res> get ingredient;
  @override
  $QuantityCopyWith<$Res> get quantity;
}

/// @nodoc
class __$$IngredientUsageImplCopyWithImpl<$Res>
    extends _$IngredientUsageCopyWithImpl<$Res, _$IngredientUsageImpl>
    implements _$$IngredientUsageImplCopyWith<$Res> {
  __$$IngredientUsageImplCopyWithImpl(
      _$IngredientUsageImpl _value, $Res Function(_$IngredientUsageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ingredient = null,
    Object? quantity = null,
  }) {
    return _then(_$IngredientUsageImpl(
      ingredient: null == ingredient
          ? _value.ingredient
          : ingredient // ignore: cast_nullable_to_non_nullable
              as Ingredient,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as Quantity,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IngredientUsageImpl
    with DiagnosticableTreeMixin
    implements _IngredientUsage {
  const _$IngredientUsageImpl(
      {required this.ingredient, required this.quantity});

  factory _$IngredientUsageImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientUsageImplFromJson(json);

  @override
  final Ingredient ingredient;
  @override
  final Quantity quantity;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'IngredientUsage(ingredient: $ingredient, quantity: $quantity)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'IngredientUsage'))
      ..add(DiagnosticsProperty('ingredient', ingredient))
      ..add(DiagnosticsProperty('quantity', quantity));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientUsageImpl &&
            (identical(other.ingredient, ingredient) ||
                other.ingredient == ingredient) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, ingredient, quantity);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientUsageImplCopyWith<_$IngredientUsageImpl> get copyWith =>
      __$$IngredientUsageImplCopyWithImpl<_$IngredientUsageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientUsageImplToJson(
      this,
    );
  }
}

abstract class _IngredientUsage implements IngredientUsage {
  const factory _IngredientUsage(
      {required final Ingredient ingredient,
      required final Quantity quantity}) = _$IngredientUsageImpl;

  factory _IngredientUsage.fromJson(Map<String, dynamic> json) =
      _$IngredientUsageImpl.fromJson;

  @override
  Ingredient get ingredient;
  @override
  Quantity get quantity;
  @override
  @JsonKey(ignore: true)
  _$$IngredientUsageImplCopyWith<_$IngredientUsageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
