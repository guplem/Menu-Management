import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/menu/enums/meal_type.dart';
import 'package:menu_management/menu/enums/week_day.dart';
import 'package:menu_management/menu/models/menu_configuration.dart';
import 'package:menu_management/menu/models/meal_time.dart';

// Alter data should be done through the static methods.
// Fetching data should be done through the listenableOf method or through the provider in the tree.
class MenuProvider extends ChangeNotifier {

  static late MenuProvider instance;

  MenuProvider() {
    instance = this;
  }

  final List<MenuConfiguration> _configurations = [
    // SATURDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // SUNDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.sunday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.sunday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.sunday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // MONDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // TUESDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.tuesday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.tuesday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.tuesday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // WEDNESDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.wednesday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.wednesday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.wednesday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // THURSDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.thursday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.thursday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.thursday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // FRIDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.friday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.friday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.friday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
  ];

  List<MenuConfiguration> get configurations => _configurations;

  static MenuConfiguration listenableOf(context, {required WeekDay weekDay,required  MealType mealType}) => getProvider<MenuProvider>(context, listen: true).get(mealType: mealType, weekDay: weekDay);

  void setData(List<MenuConfiguration> recipes) {
    _configurations.clear();
    _configurations.addAll(recipes);
    notifyListeners();
  }

  MenuConfiguration get({required WeekDay weekDay,required  MealType mealType}) {
    return configurations.firstWhere((element) {
      return element.mealTime.weekDay == weekDay && element.mealTime.mealType == mealType;
    });
  }

  static void update({required MenuConfiguration newConfiguration}) {
    final int index = instance.configurations.indexWhere((element) => element.mealTime.weekDay == newConfiguration.mealTime.weekDay && element.mealTime.mealType == newConfiguration.mealTime.mealType);
    if (index >= 0) {
      instance.configurations[index] = newConfiguration;
      instance.notifyListeners();
    } else {
      Debug.logError("MenuProvider.update: No configuration found for ${newConfiguration.mealTime.weekDay} ${newConfiguration.mealTime.mealType}");
    }
  }

}
