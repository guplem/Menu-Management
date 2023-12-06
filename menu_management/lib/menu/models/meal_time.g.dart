// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealTimeImpl _$$MealTimeImplFromJson(Map<String, dynamic> json) =>
    _$MealTimeImpl(
      weekDay: json['weekDay'] as int,
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
    );

Map<String, dynamic> _$$MealTimeImplToJson(_$MealTimeImpl instance) =>
    <String, dynamic>{
      'weekDay': instance.weekDay,
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
};
