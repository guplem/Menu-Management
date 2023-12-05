import 'package:menu_management/recipes/step.dart';

class Recipe {
  List<Step> steps;

  bool carbsRich = false;
  bool proteinRich = false;
  bool fatRich = false;


  Recipe({required this.steps});
}
