# ADR 0013: Multiple Sub-Meals per Time Slot

## Context

Two people in the household often eat different things at the same meal time (e.g., different breakfast cereals). The original model supported exactly one recipe per time slot (`Meal` had a single `Cooking? cooking` and `int people`). This made it impossible to represent per-person meal assignments.

The feature needed to support any meal type (breakfast, lunch, dinner) with an arbitrary number of independent recipes per time slot, each with its own servings count.

## Decision

Introduce a `SubMeal` Freezed model and restructure `Meal` to hold a `List<SubMeal>` instead of a single `Cooking?` + `int people`.

### Data model

- **`SubMeal`** (new): holds `Cooking? cooking` and `int people` (default 1). Represents one person's or group's food at a time slot.
- **`Meal`** (changed): holds `MealTime mealTime` and `List<SubMeal> subMeals` (default `[]`). Empty list means "no food at this time" (equivalent to disabled slot). Non-empty list with `cooking: null` means "slot exists but no recipe assigned yet".
- **`MenuConfiguration`** (changed): added `int mealCount` (default 1). Tells the generator how many sub-meals to create per time slot.

### Yield calculation

`Menu.recalculateYields` iterates over all sub-meals within all meals. The yield map is keyed by `(MealTime, subMealIndex)` record to uniquely identify each sub-meal. Each sub-meal's recipe participates independently in cook/leftover tracking.

### Shopping aggregation

`Menu.allIngredients` and `Menu.ingredientSources` iterate over sub-meals within each meal. The `peopleFactor` for a recipe sums `subMeal.people` across all sub-meals (in all meals) that reference that recipe.

### Menu generator

For each `MenuConfiguration`, the generator creates `mealCount` sub-meals. The first sub-meal gets the primary recipe (assigned by the existing algorithm). Additional sub-meals get different recipes from the same pool, avoiding duplicates within a slot. Default people per sub-meal: `ceil(2 / mealCount)`.

### Persistence

`Meal.fromJson` includes a migration that converts old format (`{cooking, people, mealTime}`) to the new format (`{mealTime, subMeals: [{cooking, people}]}`). The migration runs automatically when loading `.tsm` files saved with the old format. New files serialize using the `subMeals` structure.

### UI

- **Menu configuration page**: added a meal count control (+/- buttons) per time slot.
- **Menu grid**: each meal card displays all sub-meals vertically. Each sub-meal has its own recipe name, cook/leftovers chip, and people counter. Recipe picking and people adjustment work per sub-meal.
- **Cook mode**: launches from a specific sub-meal's cook chip, passing the correct `subMealIndex` to `servingsForCookEvent`.

### Methods that gained a `subMealIndex` parameter

- `Menu.copyWithUpdatedRecipe`
- `Menu.copyWithClearedSubMeal` (renamed from `copyWithClearedMeal`)
- `Menu.copyWithUpdatedPeople`
- `MultiWeekMenu.servingsForCookEvent`
- `Meal.copyWithSubMealCooking` (new, replaces `copyWithUpdatedCooking`)
- `Meal.copyWithSubMealPeople` (new)

## Consequences

- A time slot can hold 1+ independent recipes, each with its own servings count.
- Existing `.tsm` files load correctly via automatic migration.
- The yield, shopping, and cook mode systems all respect per-sub-meal granularity.
- The `mealCount` configuration is not persisted (generated on-demand, like all `MenuConfiguration` values).
- The generator's additional sub-meal assignment is simpler than the primary algorithm (no backfilling or gap-filling for secondary sub-meals).
