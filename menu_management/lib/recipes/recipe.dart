import 'package:menu_management/recipes/step.dart';

class Recipe {
  String name;
  List<Step> steps;

  bool carbs = false;
  bool proteins = false;
  bool vegetables = false;


  Recipe({required this.name, required this.steps});
}
