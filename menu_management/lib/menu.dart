import 'package:menu_management/meal.dart';
import 'package:menu_management/meal_time.dart';

class Menu {
  final int headcount;
  final Map<MealTime, Meal> meals = {};

  Menu({required this.headcount});
}
