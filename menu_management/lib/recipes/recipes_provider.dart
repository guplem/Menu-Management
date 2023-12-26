import 'package:flutter/foundation.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:menu_management/recipes/models/recipe.dart';
import 'package:menu_management/recipes/models/result.dart';

import '../flutter_essentials/library.dart';

// Alter data should be done through the static methods.
// Fetching data should be done through the listenableOf method or through the provider in the tree.
class RecipesProvider extends ChangeNotifier {
  static late RecipesProvider instance;

  RecipesProvider() {
    instance = this;
  }

  final List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  static Recipe listenableOf(context, recipeId) => getProvider<RecipesProvider>(context, listen: true).get(recipeId);

  //#region RECIPES
  void setData(List<Recipe> recipes) {
    _recipes.clear();
    _recipes.addAll(recipes);
    notifyListeners();
  }

  Recipe get(String recipeId) {
    return recipes.firstWhere((element) => element.id == recipeId);
  }

  static void addOrUpdate({required Recipe newRecipe}) {
    final int index = instance.recipes.indexWhere((element) => element.id == newRecipe.id);
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
  static void addOrUpdateInstruction({required String recipeId, required Instruction newInstruction}) {
    final Recipe recipeToUpdate = instance.recipes.firstWhere((element) => element.id == recipeId);
    List<Instruction> instructions = [...recipeToUpdate.instructions];
    final int index = recipeToUpdate.instructions.indexWhere((element) => element.id == newInstruction.id);
    if (index >= 0) {
      instructions[index] = newInstruction;
    } else {
      instructions.add(newInstruction);
    }
    Recipe updatedRecipe = recipeToUpdate.copyWith(instructions: instructions);
    addOrUpdate(newRecipe: updatedRecipe);
  }

  static void removeInstruction({required String recipeId, required String instructionId}) {
    // TODO: Ask for confirmation (generic method with all "removes")
    final Recipe recipeToUpdate = instance.recipes.firstWhere((element) => element.id == recipeId);
    List<Instruction> instructions = [...recipeToUpdate.instructions];
    instructions.removeWhere((element) => element.id == instructionId);
    Recipe updatedRecipe = recipeToUpdate.copyWith(instructions: instructions);
    addOrUpdate(newRecipe: updatedRecipe);
  }

  static void reorderInstructions({required String recipeId, required int oldIndex, required int newIndex}) {
    final Recipe recipeToUpdate = instance.recipes.firstWhere((element) => element.id == recipeId);
    List<Instruction> instructions = [...recipeToUpdate.instructions];
    Instruction instructionToMove = instructions.removeAt(oldIndex);
    instructions.insert(newIndex, instructionToMove);
    Recipe updatedRecipe = recipeToUpdate.copyWith(instructions: instructions);
    addOrUpdate(newRecipe: updatedRecipe);
  }
  //#endregion

  //#region RESULTS
  static Map<Result, bool> getRecipeInputsAvailability({required String recipeId, String? forInstruction}) {
    final Recipe recipe = instance.get(recipeId);
    final List<Result> possibleInputs = recipe.instructions.expand((Instruction element) => element.outputs).toList();
    final List<String> alreadyTakenInputs = recipe.instructions
        .where((Instruction instruction) => forInstruction == null || forInstruction != instruction.id)
        .expand((Instruction instruction) => instruction.inputs)
        .toList();
    final int instructionIndex = recipe.instructions.indexWhere((Instruction instruction) => instruction.id == forInstruction);
    final List<Result> outputsOfNextInstructions = recipe.instructions
        .sublist(instructionIndex + 1)
        .expand((Instruction instruction) => instruction.outputs)
        .toList();
    return {for (Result element in possibleInputs) element: !alreadyTakenInputs.contains(element.id) && forInstruction != element.id && !outputsOfNextInstructions.contains(element)};
  }

  static List<Result> getResults(List<String> inputs) {
    List<Result> results = [];
    for(Recipe recipe in instance.recipes) {
      for(Instruction instruction in recipe.instructions) {
        for(Result output in instruction.outputs) {
          if(inputs.contains(output.id)) {
            results.add(output);
          }
        }
      }
    }
    return results;
  }
  //#endregion
}
