// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_usage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IngredientUsage _$IngredientUsageFromJson(Map<String, dynamic> json) =>
    _IngredientUsage(ingredient: json['ingredient'] as String, quantity: Quantity.fromJson(json['quantity'] as Map<String, dynamic>));

Map<String, dynamic> _$IngredientUsageToJson(_IngredientUsage instance) => <String, dynamic>{
  'ingredient': instance.ingredient,
  'quantity': instance.quantity,
};
