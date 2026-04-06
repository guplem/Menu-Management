// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Quantity _$QuantityFromJson(Map<String, dynamic> json) =>
    _Quantity(amount: (json['amount'] as num).toDouble(), unit: $enumDecode(_$UnitEnumMap, json['unit']));

Map<String, dynamic> _$QuantityToJson(_Quantity instance) => <String, dynamic>{'amount': instance.amount, 'unit': _$UnitEnumMap[instance.unit]!};

const _$UnitEnumMap = {
  Unit.grams: 'grams',
  Unit.centiliters: 'centiliters',
  Unit.pieces: 'pieces',
  Unit.tablespoons: 'tablespoons',
  Unit.teaspoons: 'teaspoons',
};
