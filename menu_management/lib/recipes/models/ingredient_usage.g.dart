// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_usage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IngredientUsageImpl _$$IngredientUsageImplFromJson(
        Map<String, dynamic> json) =>
    _$IngredientUsageImpl(
      ingredient:
          Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>),
      quantity: Quantity.fromJson(json['quantity'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$IngredientUsageImplToJson(
        _$IngredientUsageImpl instance) =>
    <String, dynamic>{
      'ingredient': instance.ingredient,
      'quantity': instance.quantity,
    };
