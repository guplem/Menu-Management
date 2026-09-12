// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_meal_requirement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IngredientMealRequirement _$IngredientMealRequirementFromJson(
  Map<String, dynamic> json,
) => _IngredientMealRequirement(
  weekIndex: (json['weekIndex'] as num).toInt(),
  mealTime: MealTime.fromJson(json['mealTime'] as Map<String, dynamic>),
  subMealIndex: (json['subMealIndex'] as num).toInt(),
  recipeId: json['recipeId'] as String,
  recipeName: json['recipeName'] as String,
  people: (json['people'] as num).toInt(),
  isCookEvent: json['isCookEvent'] as bool,
  quantities:
      (json['quantities'] as List<dynamic>?)
          ?.map((e) => Quantity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$IngredientMealRequirementToJson(
  _IngredientMealRequirement instance,
) => <String, dynamic>{
  'weekIndex': instance.weekIndex,
  'mealTime': instance.mealTime.toJson(),
  'subMealIndex': instance.subMealIndex,
  'recipeId': instance.recipeId,
  'recipeName': instance.recipeName,
  'people': instance.people,
  'isCookEvent': instance.isCookEvent,
  'quantities': instance.quantities.map((e) => e.toJson()).toList(),
};
