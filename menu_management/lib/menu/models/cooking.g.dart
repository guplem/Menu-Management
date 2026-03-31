// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Cooking _$CookingFromJson(Map<String, dynamic> json) => _Cooking(
  recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
  yield: (json['yield'] as num).toInt(),
);

Map<String, dynamic> _$CookingToJson(_Cooking instance) => <String, dynamic>{
  'recipe': instance.recipe,
  'yield': instance.yield,
};
