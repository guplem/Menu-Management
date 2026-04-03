// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  link: json['link'] as String,
  itemsPerPack: (json['itemsPerPack'] as num?)?.toInt() ?? 1,
  quantityPerItem: (json['quantityPerItem'] as num).toDouble(),
  unit: $enumDecode(_$UnitEnumMap, json['unit']),
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'link': instance.link,
  'itemsPerPack': instance.itemsPerPack,
  'quantityPerItem': instance.quantityPerItem,
  'unit': _$UnitEnumMap[instance.unit]!,
};

const _$UnitEnumMap = {
  Unit.grams: 'grams',
  Unit.centiliters: 'centiliters',
  Unit.pieces: 'pieces',
  Unit.tablespoons: 'tablespoons',
  Unit.teaspoons: 'teaspoons',
};
