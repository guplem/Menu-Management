// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MealTime _$MealTimeFromJson(Map<String, dynamic> json) =>
    _MealTime(weekDay: $enumDecode(_$WeekDayEnumMap, json['weekDay']), mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']));

Map<String, dynamic> _$MealTimeToJson(_MealTime instance) => <String, dynamic>{
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

const _$MealTypeEnumMap = {MealType.breakfast: 'breakfast', MealType.lunch: 'lunch', MealType.dinner: 'dinner'};
