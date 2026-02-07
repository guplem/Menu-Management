// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MenuImpl _$$MenuImplFromJson(Map<String, dynamic> json) =>
    _$MenuImpl(meals: (json['meals'] as List<dynamic>?)?.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList() ?? const []);

Map<String, dynamic> _$$MenuImplToJson(_$MenuImpl instance) => <String, dynamic>{'meals': instance.meals};
