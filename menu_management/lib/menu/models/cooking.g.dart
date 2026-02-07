// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CookingImpl _$$CookingImplFromJson(Map<String, dynamic> json) =>
    _$CookingImpl(recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>), yield: (json['yield'] as num).toInt());

Map<String, dynamic> _$$CookingImplToJson(_$CookingImpl instance) => <String, dynamic>{'recipe': instance.recipe, 'yield': instance.yield};
