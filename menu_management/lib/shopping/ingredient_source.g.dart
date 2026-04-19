// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IngredientSource _$IngredientSourceFromJson(Map<String, dynamic> json) =>
    _IngredientSource(
      recipeName: json['recipeName'] as String,
      perServingQuantities:
          (json['perServingQuantities'] as List<dynamic>?)
              ?.map((e) => Quantity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      servings: (json['servings'] as num).toInt(),
    );

Map<String, dynamic> _$IngredientSourceToJson(_IngredientSource instance) =>
    <String, dynamic>{
      'recipeName': instance.recipeName,
      'perServingQuantities': instance.perServingQuantities
          .map((e) => e.toJson())
          .toList(),
      'servings': instance.servings,
    };
