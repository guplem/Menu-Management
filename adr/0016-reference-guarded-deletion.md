# ADR 0016: Reference-Guarded Deletion with Cascade Cleanup

## Context

Deleting an ingredient, a recipe, or a recipe instruction previously removed only that entity, ignoring anything that referenced it:

- Deleting an `Ingredient` used by a `Recipe`'s `IngredientUsage` left a dangling ingredient ID, which crashed at runtime wherever the code resolved that ID back to an `Ingredient`.
- Deleting a `Recipe` scheduled in the current menu left a stale `Cooking.recipeId` in the corresponding `SubMeal`, pointing at a recipe that no longer existed.
- Deleting an `Instruction` that produced a `Result` consumed by a later instruction (see ADR 0005) left a dangling ID in that later instruction's `inputs` list.

All three call sites (`IngredientsProvider.remove`, `RecipesProvider.remove`, `RecipesProvider.removeInstruction`) had a `// TODO: Ask for confirmation` comment. The goal was to close that gap: warn the user when a delete has consequences elsewhere, show what will be affected, and leave no dangling references either way -- whether the user confirms or cancels.

## Decision

Each delete flow now follows the same shape: **find references -> confirm if any exist -> delete and cascade-clean -> offer undo that restores both the entity and the cleaned references.**

### Reference-finding and cleanup live on the models, not the providers

Per ADR 0001 and ADR 0009, cross-entity lookups are parameterized methods on Freezed models, not provider or service code:

- `Ingredient.findReferencingRecipes({required List<Recipe> recipes})` (`menu_management/lib/ingredients/models/ingredient.dart`) returns every recipe with an instruction whose `ingredientsUsed` includes the ingredient.
- `Recipe.copyWithRemovedIngredientUsages({required String ingredientId})` (`menu_management/lib/recipes/models/recipe.dart`) returns a copy with that ingredient's usages stripped from every instruction.
- `Recipe.findDependentInstructions(String instructionId)` returns the instructions that consume any of the target instruction's `outputs` as an `input`.
- `Recipe.copyWithRemovedInstruction({required String instructionId})` removes the instruction and strips its output IDs from every remaining instruction's `inputs`.
- `MultiWeekMenu.findReferencingMeals(String recipeId)` (`menu_management/lib/menu/models/multi_week_menu.dart`) returns one `(weekIndex, mealTime)` record per meal slot where any `SubMeal.cooking.recipeId` matches, ordered chronologically by week then by `Meal.goesBefore`.
- `MultiWeekMenu.copyWithClearedRecipe({required String recipeId, required List<Recipe> recipes})` sets `cooking` to `null` on every matching sub-meal (the sub-meal itself, including its `people` count, is kept) and recalculates yields via the existing `copyWithUpdatedYields`.

### Confirmation and orchestration live at the UI call site

`RecipesProvider.remove` and `IngredientsProvider.remove` still do plain removal with no cascade logic; their doc comments now read "Reference checks and confirmation happen at the call sites (UI layer) before calling this," replacing the old TODOs. The widgets orchestrate the cascade because they are the layer allowed to hold `BuildContext` and read multiple providers at once:

- `IngredientsPage`'s delete button (`menu_management/lib/ingredients/widgets/ingredients_page.dart`) checks `findReferencingRecipes`, confirms if non-empty, then calls `RecipesProvider.addOrUpdate` with `copyWithRemovedIngredientUsages` for each affected recipe before removing the ingredient. Undo restores the ingredient and re-adds the original (unmodified) recipes.
- `RecipesPage._deleteSelectedRecipe` (`menu_management/lib/recipes/widgets/recipes_page.dart`) checks `MenuProvider.instance.multiWeekMenu?.findReferencingMeals`, confirms if non-empty, then calls `MenuProvider.setMultiWeekMenu` with `copyWithClearedRecipe` before removing the recipe. Undo restores the recipe and puts the original menu back with `MenuProvider.setMultiWeekMenu(menu)`.
- `RecipePage`'s per-instruction delete button (`menu_management/lib/recipes/widgets/recipe_page.dart`) checks `recipe.findDependentInstructions`, confirms if non-empty, then calls `RecipesProvider.removeInstruction`, which itself delegates to `Recipe.copyWithRemovedInstruction` (see next section). Undo restores the whole pre-delete `Recipe`.

One exception to "cascade lives in the widget": `RecipesProvider.removeInstruction` (`menu_management/lib/recipes/recipes_provider.dart`) now calls `recipeToUpdate.copyWithRemovedInstruction(instructionId:)` directly instead of the widget doing it. Instruction and its dependents are fields of the *same* `Recipe`, so the cleanup is a single-entity operation the provider can already express with its normal `addOrUpdate`. The ingredient-recipe and recipe-menu cases cross entity boundaries (two different providers), which is why those cascades are orchestrated in the widget instead.

### Shared confirmation dialog

`showDeleteConfirmationDialog` (`menu_management/lib/flutter_essentials/widgets/delete_confirmation_dialog.dart`, exported from `library.dart` per ADR 0007) is a single reusable function: `title`, `message`, and `affectedItems` (rendered as a bulleted list, scrollable past 60% of screen height). It returns `true` only on explicit confirmation (`Cancel` or dismissing the dialog both resolve to `false`). All three call sites build their own `title`/`message`/`affectedItems` text; the dialog itself has no domain knowledge.

### Skip the dialog when there is nothing to warn about

If the reference list is empty, no dialog is shown and the delete proceeds straight to the existing immediate-delete-with-undo-snackbar UX. The confirmation step is additive, not a replacement for the fast path.

### MenuProvider gained a second, unrelated piece of state: the active menu

`RecipesPage` needs to know the current menu's contents to check recipe references, but per ADR 0008 the generated `MultiWeekMenu` was owned only by `MenuPage`'s local `State`, invisible to any other page and gone once `MenuPage` was popped. Two alternatives were considered:

1. Thread the active menu through navigation (e.g., a shared ancestor widget or `InheritedWidget`) so `RecipesPage` could read it without a provider change.
2. Mirror the menu into `MenuProvider` as a new field, alongside its existing 21 `MenuConfiguration` slots.

Option 2 was chosen because `MenuProvider` is already the app-lifetime singleton every page can reach via `Provider.of`/`.instance`, and `RecipesPage` and `MenuPage` are siblings under the same navigation rail (`hub.dart`) with no natural shared ancestor to hang an `InheritedWidget` from. The trade-off, spelled out in Consequences below, is that `MenuProvider` (described in ADR 0002 as the "fixed-grid provider" for `MenuConfiguration`) now also holds one mutable `MultiWeekMenu?` that has nothing to do with configuration.

`MenuProvider` (`menu_management/lib/menu/menu_provider.dart`) exposes:
- `MultiWeekMenu? get multiWeekMenu` -- the menu currently (or last) shown in `MenuPage`; `null` until a menu is generated or loaded.
- `static void setMultiWeekMenu(MultiWeekMenu? multiWeekMenu)` -- replaces it and calls `notifyListeners()`.

`MenuPage`'s `_multiWeekMenu` field (`menu_management/lib/menu/widgets/menu_page.dart`) keeps its own copy as the source of truth for the page's own rendering (unchanged from ADR 0008), but its setter now also calls `MenuProvider.setMultiWeekMenu(value)`, so every edit inside `MenuPage` (recipe swap, add/remove week, people count, etc.) mirrors into the provider. `initState` seeds the provider via `WidgetsBinding.instance.addPostFrameCallback`, because `setMultiWeekMenu` calls `notifyListeners()` and Flutter disallows notifying listeners mid-build.

## Consequences

- All three delete flows are now safe: no dangling ingredient IDs in `IngredientUsage`, no dangling `recipeId` in `Cooking`, no dangling result IDs in `Instruction.inputs`.
- Undo is symmetric with the cascade: the snackbar's "Undo" action restores not just the deleted entity but also every recipe/menu it had modified, by closing over the pre-cascade objects (`referencingRecipes`, `menu`) in the callback.
- `MenuProvider.multiWeekMenu` is a best-effort mirror, not a guaranteed-fresh source of truth. It is set only when `MenuPage` is open or was opened at least once this session. Every current generate/load path pushes a new `MenuPage`, which replaces the mirror, but nothing ever resets it to `null` -- it outlives the page it came from, and it is not touched when a `.tsr` recipe file is loaded that removes recipes the mirrored menu still references. `MenuConfigurationPage` also reads the mirror on purpose: it borrows the start date of the active menu to name its day columns, so the grid can show the dates of a menu that the user already closed, and it falls back to the Saturday-first `WeekDay` order before any menu exists. `RecipesPage._deleteSelectedRecipe` tolerates this because `findReferencingMeals` is a plain string comparison with no assumption that every `recipeId` it finds still resolves to a loaded `Recipe`; worst case, a stale mirrored menu under-reports or over-reports references for a menu the user is no longer looking at, but it cannot crash.
- `MenuProvider` now has two unrelated responsibilities: the fixed 21-slot `MenuConfiguration` grid (ADR 0002) and this one mutable "active menu" reference. A future reviewer of ADR 0002 should be aware the "fixed-grid provider" description is no longer the whole picture.
- The reference-check methods intentionally cascade-delete rather than block the deletion outright. The user is warned and shown exactly what will be cleaned up, but there is no "cannot delete while referenced" mode. This matches the app's existing delete-then-undo pattern (immediate action, reversible) rather than introducing a new blocking-validation pattern.
- `showDeleteConfirmationDialog` is domain-agnostic and reusable; a fourth delete flow needing the same warn-and-list treatment (e.g., deleting a `Product` referenced by shopping calculations) can reuse it without changes.
- Test coverage: `menu_management/test/delete_reference_guard_test.dart` covers all six new model methods plus `MenuProvider.setMultiWeekMenu`, and `menu_management/test/delete_confirmation_dialog_test.dart` covers the dialog's confirm/cancel/list-rendering behavior. Neither test file drives the full widget-level cascade (dialog shown from `IngredientsPage`/`RecipesPage`/`RecipePage`); that orchestration is exercised manually.
