import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/menu/enums/meal_type.dart';
import 'package:menu_management/menu/models/menu_configuration.dart';
import 'package:menu_management/menu/models/meal_time.dart';

class MenuProvider extends ChangeNotifier {

  static late MenuProvider instance;

  MenuProvider() {
    instance = this;
  }

  final List<MenuConfiguration> _configurations = [
    // SATURDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: 0, mealType: MealType.breakfast), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 0, mealType: MealType.lunch), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 0, mealType: MealType.dinner), availableCookingTime: 60, requiresMeal: true),
    // SUNDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: 1, mealType: MealType.breakfast), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 1, mealType: MealType.lunch), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 1, mealType: MealType.dinner), availableCookingTime: 60, requiresMeal: true),
    // MONDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: 2, mealType: MealType.breakfast), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 2, mealType: MealType.lunch), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 2, mealType: MealType.dinner), availableCookingTime: 60, requiresMeal: true),
    // TUESDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: 3, mealType: MealType.breakfast), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 3, mealType: MealType.lunch), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 3, mealType: MealType.dinner), availableCookingTime: 60, requiresMeal: true),
    // WEDNESDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: 4, mealType: MealType.breakfast), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 4, mealType: MealType.lunch), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 4, mealType: MealType.dinner), availableCookingTime: 60, requiresMeal: true),
    // THURSDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: 5, mealType: MealType.breakfast), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 5, mealType: MealType.lunch), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 5, mealType: MealType.dinner), availableCookingTime: 60, requiresMeal: true),
    // FRIDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: 6, mealType: MealType.breakfast), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 6, mealType: MealType.lunch), availableCookingTime: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: 6, mealType: MealType.dinner), availableCookingTime: 60, requiresMeal: true),
  ];

  List<MenuConfiguration> get configurations => _configurations;

  void setData(List<MenuConfiguration> recipes) {
    _configurations.clear();
    _configurations.addAll(recipes);
    notifyListeners();
  }

  static MenuConfiguration get({required int weekDay,required  MealType mealType}) {
    return instance._get(weekDay: weekDay, mealType: mealType);
  }

  MenuConfiguration _get({required int weekDay,required  MealType mealType}) {
    return instance.configurations.firstWhere((element) {
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
