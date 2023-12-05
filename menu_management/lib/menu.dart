import 'package:menu_management/menu/meal.dart';
import 'package:menu_management/menu/meal_time.dart';

class Menu {
  final int headcount;
  final Map<MealTime, Meal> meals = {};

  Menu({required this.headcount});
}
