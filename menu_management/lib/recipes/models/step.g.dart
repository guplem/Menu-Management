// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StepImpl _$$StepImplFromJson(Map<String, dynamic> json) => _$StepImpl(
      ingredientUsage: (json['ingredientUsage'] as List<dynamic>)
          .map((e) => IngredientUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$$StepImplToJson(_$StepImpl instance) =>
    <String, dynamic>{
      'ingredientUsage': instance.ingredientUsage,
      'description': instance.description,
    };
