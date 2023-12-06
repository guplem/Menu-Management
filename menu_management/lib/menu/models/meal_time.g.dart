// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealTimeImpl _$$MealTimeImplFromJson(Map<String, dynamic> json) =>
    _$MealTimeImpl(
      weekDay: $enumDecode(_$WeekDayEnumMap, json['weekDay']),
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
    );

Map<String, dynamic> _$$MealTimeImplToJson(_$MealTimeImpl instance) =>
    <String, dynamic>{
      'weekDay': _$WeekDayEnumMap[instance.weekDay]!,
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
    };

const _$WeekDayEnumMap = {
  WeekDay.saturday: 'saturday',
  WeekDay.sunday: 'sunday',
  WeekDay.monday: 'monday',
  WeekDay.tuesday: 'tuesday',
  WeekDay.wednesday: 'wednesday',
  WeekDay.thursday: 'thursday',
  WeekDay.friday: 'friday',
};

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
};
