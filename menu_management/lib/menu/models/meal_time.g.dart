// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealTimeImpl _$$MealTimeImplFromJson(Map<String, dynamic> json) =>
    _$MealTimeImpl(
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
      weekDay: json['weekDay'] as int,
    );

Map<String, dynamic> _$$MealTimeImplToJson(_$MealTimeImpl instance) =>
    <String, dynamic>{
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'weekDay': instance.weekDay,
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
};
