# ADR 0009: Cooking Model Stores Recipe ID Instead of Full Recipe

## Context

The `Cooking` model embedded a full `Recipe` object, causing `.tsm` files to duplicate entire recipe trees (instructions, ingredient usages, nutritional flags) for every meal slot. This created several problems:

1. `.tsm` files were bloated with redundant data.
2. Updating a recipe in the recipe book did not propagate to already-saved menus, since menus held their own copies.
3. The `IngredientUsage` model already stored ingredient references as UUID strings, making `Cooking`'s full-object embedding inconsistent.

## Decision

Change `Cooking` from `required Recipe recipe` to `required String recipeId`. All model methods that need recipe data receive a `List<Recipe> recipes` parameter (see ADR 0001 for the parameterized-methods pattern).

Key design choices:

- **Parameterized methods, not a service layer**: Methods like `allIngredients`, `copyWithUpdatedYields`, and `toStringBeautified` on `Menu` and `MultiWeekMenu` accept `List<Recipe> recipes`. This keeps models pure and testable without introducing provider dependencies.
- **`ref_name` for human readability**: `Persistency.saveMenu` post-processes the JSON to inject a `ref_name` field next to each `recipeId`. This field is for humans reading the file; `fromJson` ignores it. Similarly, `Persistency.saveData` injects `ref_name` next to ingredient IDs in `IngredientUsage` entries.
- **Validation on load**: When loading a `.tsm` file, each `recipeId` is checked against the loaded recipes. Meals with missing recipe references have their cooking set to null with a warning logged (not an assertion, since this is an expected condition when files drift).
- **No backward compatibility for old `.tsm` format**: Old files with embedded `Recipe` objects will fail to parse. This is acceptable because menus are transient and regenerable.

## Consequences

- `.tsm` files are dramatically smaller (each cooking entry stores a UUID + yield instead of the full recipe tree).
- Recipe identity uses string comparison, which is faster and unambiguous.
- Loading a menu requires the recipe book to be loaded first. The startup flow already enforces this order.
- Callers pass `RecipesProvider.instance.recipes` at call sites.
- Old `.tsm` files with embedded recipe objects are incompatible. Default asset files were regenerated in the new format.
