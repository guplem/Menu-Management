// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quantity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Quantity _$QuantityFromJson(Map<String, dynamic> json) {
  return _Quantity.fromJson(json);
}

/// @nodoc
mixin _$Quantity {
  double get amount => throw _privateConstructorUsedError;
  Unit get unit => throw _privateConstructorUsedError;

  /// Serializes this Quantity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Quantity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuantityCopyWith<Quantity> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuantityCopyWith<$Res> {
  factory $QuantityCopyWith(Quantity value, $Res Function(Quantity) then) = _$QuantityCopyWithImpl<$Res, Quantity>;
  @useResult
  $Res call({double amount, Unit unit});
}

/// @nodoc
class _$QuantityCopyWithImpl<$Res, $Val extends Quantity> implements $QuantityCopyWith<$Res> {
  _$QuantityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Quantity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? amount = null, Object? unit = null}) {
    return _then(
      _value.copyWith(
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as Unit,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuantityImplCopyWith<$Res> implements $QuantityCopyWith<$Res> {
  factory _$$QuantityImplCopyWith(_$QuantityImpl value, $Res Function(_$QuantityImpl) then) = __$$QuantityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double amount, Unit unit});
}

/// @nodoc
class __$$QuantityImplCopyWithImpl<$Res> extends _$QuantityCopyWithImpl<$Res, _$QuantityImpl> implements _$$QuantityImplCopyWith<$Res> {
  __$$QuantityImplCopyWithImpl(_$QuantityImpl _value, $Res Function(_$QuantityImpl) _then) : super(_value, _then);

  /// Create a copy of Quantity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? amount = null, Object? unit = null}) {
    return _then(
      _$QuantityImpl(
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as Unit,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuantityImpl with DiagnosticableTreeMixin implements _Quantity {
  const _$QuantityImpl({required this.amount, required this.unit});

  factory _$QuantityImpl.fromJson(Map<String, dynamic> json) => _$$QuantityImplFromJson(json);

  @override
  final double amount;
  @override
  final Unit unit;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Quantity(amount: $amount, unit: $unit)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Quantity'))
      ..add(DiagnosticsProperty('amount', amount))
      ..add(DiagnosticsProperty('unit', unit));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuantityImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, amount, unit);

  /// Create a copy of Quantity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuantityImplCopyWith<_$QuantityImpl> get copyWith => __$$QuantityImplCopyWithImpl<_$QuantityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuantityImplToJson(this);
  }
}

abstract class _Quantity implements Quantity {
  const factory _Quantity({required final double amount, required final Unit unit}) = _$QuantityImpl;

  factory _Quantity.fromJson(Map<String, dynamic> json) = _$QuantityImpl.fromJson;

  @override
  double get amount;
  @override
  Unit get unit;

  /// Create a copy of Quantity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuantityImplCopyWith<_$QuantityImpl> get copyWith => throw _privateConstructorUsedError;
}
