// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuantityImpl _$$QuantityImplFromJson(Map<String, dynamic> json) =>
    _$QuantityImpl(
      amount: (json['amount'] as num).toDouble(),
      unit: $enumDecode(_$UnitEnumMap, json['unit']),
    );

Map<String, dynamic> _$$QuantityImplToJson(_$QuantityImpl instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'unit': _$UnitEnumMap[instance.unit]!,
    };

const _$UnitEnumMap = {
  Unit.grams: 'grams',
  Unit.centiliters: 'centiliters',
  Unit.pieces: 'pieces',
  Unit.tablespoons: 'tablespoons',
  Unit.teaspoons: 'teaspoons',
};
