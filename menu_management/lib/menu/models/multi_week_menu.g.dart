// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_week_menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MultiWeekMenu _$MultiWeekMenuFromJson(Map<String, dynamic> json) =>
    _MultiWeekMenu(weeks: (json['weeks'] as List<dynamic>?)?.map((e) => Menu.fromJson(e as Map<String, dynamic>)).toList() ?? const []);

Map<String, dynamic> _$MultiWeekMenuToJson(_MultiWeekMenu instance) => <String, dynamic>{'weeks': instance.weeks};
