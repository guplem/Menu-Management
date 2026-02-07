import 'package:flutter/foundation.dart';
import 'package:menu_management/ingredients/ingredients_provider.dart';
import 'package:menu_management/recipes/enums/recipe_type.dart';
import 'package:menu_management/recipes/models/ingredient_usage.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:menu_management/recipes/models/recipe.dart';
import 'package:menu_management/recipes/models/result.dart';

import '../flutter_essentials/library.dart';

// Alter data should be done through the static methods.
// Fetching data should be done through the listenableOf method or through the provider in the tree.
class RecipesProvider extends ChangeNotifier {
  factory RecipesProvider() {
    return instance;
  }

  static final RecipesProvider instance = RecipesProvider._privateConstructor();
  RecipesProvider._privateConstructor() {
    Debug.log("Creating RecipesProvider instance", maxStackTraceRows: 4);
  }

  final List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  static Recipe listenableOf(context, recipeId) =>
      getProvider<RecipesProvider>(context, listen: true).get(recipeId);

  //#region RECIPES
  void setData(List<Recipe> recipes) {
    _recipes.clear();
    _recipes.addAll(recipes);
    notifyListeners();
    _checkIngredientsValidity();
  }

  Recipe get(String recipeId) {
    return recipes.firstWhere((element) => element.id == recipeId);
  }

  List<Recipe> getOfType({
    required RecipeType type,
    bool? carbs,
    bool? proteins,
    bool? vegetables,
  }) {
    return recipes.where((recipe) {
      if (recipe.type != type) return false;
      if (carbs != null && recipe.carbs != carbs) return false;
      if (proteins != null && recipe.proteins != proteins) return false;
      if (vegetables != null && recipe.vegetables != vegetables) return false;
      return true;
    }).toList();
  }

  static void addOrUpdate({required Recipe newRecipe}) {
    final int index = instance.recipes.indexWhere(
      (element) => element.id == newRecipe.id,
    );
    if (index >= 0) {
      instance.recipes[index] = newRecipe;
    } else {
      instance.recipes.add(newRecipe);
    }
    instance.notifyListeners();
  }

  static void remove({required String recipeId}) {
    // TODO: Ask for confirmation (generic method with all "removes")
    instance.recipes.removeWhere((element) => element.id == recipeId);
    instance.notifyListeners();
  }
  //#endregion

  //#region INSTRUCTIONS
  static void addOrUpdateInstruction({
    required String recipeId,
    required Instruction newInstruction,
  }) {
    Debug.logWarning(instance.recipes.isEmpty, "No recipes found");
    final Recipe recipeToUpdate = instance.recipes.firstWhere(
      (element) => element.id == recipeId,
    );
    List<Instruction> instructions = [...recipeToUpdate.instructions];
    final int index = recipeToUpdate.instructions.indexWhere(
      (element) => element.id == newInstruction.id,
    );
    if (index >= 0) {
      instructions[index] = newInstruction;
    } else {
      instructions.add(newInstruction);
    }
    Recipe updatedRecipe = recipeToUpdate.copyWith(instructions: instructions);
    addOrUpdate(newRecipe: updatedRecipe);
  }

  static void removeInstruction({
    required String recipeId,
    required String instructionId,
  }) {
    // TODO: Ask for confirmation (generic method with all "removes")
    final Recipe recipeToUpdate = instance.recipes.firstWhere(
      (element) => element.id == recipeId,
    );
    List<Instruction> instructions = [...recipeToUpdate.instructions];
    instructions.removeWhere((element) => element.id == instructionId);
    Recipe updatedRecipe = recipeToUpdate.copyWith(instructions: instructions);
    addOrUpdate(newRecipe: updatedRecipe);
  }

  static void reorderInstructions({
    required String recipeId,
    required int oldIndex,
    required int newIndex,
  }) {
    final Recipe recipeToUpdate = instance.recipes.firstWhere(
      (element) => element.id == recipeId,
    );
    List<Instruction> instructions = [...recipeToUpdate.instructions];
    Instruction instructionToMove = instructions.removeAt(oldIndex);
    instructions.insert(newIndex, instructionToMove);
    Recipe updatedRecipe = recipeToUpdate.copyWith(instructions: instructions);
    addOrUpdate(newRecipe: updatedRecipe);
  }
  //#endregion

  //#region RESULTS
  Map<Result, bool> getRecipeInputsAvailability({
    required String recipeId,
    String? forInstruction,
  }) {
    final Recipe recipe = instance.get(recipeId);
    final List<Result> possibleInputs = recipe.instructions
        .expand((Instruction element) => element.outputs)
        .toList();
    final List<String> alreadyTakenInputs = recipe.instructions
        .where(
          (Instruction instruction) =>
              forInstruction == null || forInstruction != instruction.id,
        )
        .expand((Instruction instruction) => instruction.inputs)
        .toList();
    int instructionIndex = recipe.instructions.indexWhere(
      (Instruction instruction) => instruction.id == forInstruction,
    );
    final List<Result> outputsOfNextInstructions = instructionIndex == -1
        ? []
        : recipe.instructions
              .sublist(instructionIndex + 1)
              .expand((Instruction instruction) => instruction.outputs)
              .toList();
    final Map<Result, bool> inputsAvailability = {
      for (Result element in possibleInputs)
        element:
            !alreadyTakenInputs.contains(element.id) &&
            forInstruction != element.id &&
            !outputsOfNextInstructions.contains(element),
    };
    return inputsAvailability;
  }

  List<Result> getResults(List<String> inputs) {
    List<Result> results = [];
    for (Recipe recipe in instance.recipes) {
      for (Instruction instruction in recipe.instructions) {
        for (Result output in instruction.outputs) {
          if (inputs.contains(output.id)) {
            results.add(output);
          }
        }
      }
    }
    return results;
  }
  //#endregion

  void _checkIngredientsValidity() {
    for (Recipe recipe in recipes) {
      for (Instruction instruction in recipe.instructions) {
        for (IngredientUsage usage in instruction.ingredientsUsed) {
          // Just to check that nothing breaks and it is found.
          IngredientsProvider.instance.get(usage.ingredient);
          // TODO: wrap the "get" in a try-catch and display a warning if an ingredient is not found
        }
      }
    }
  }
}
