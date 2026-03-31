# ADR 0004: Menu Generation Algorithm

## Context

The app needs to automatically generate a week of meals (7 days x 3 meals = 21 slots) from the user's recipe collection, respecting time constraints, nutritional balance, and storage capabilities.

## Decision

Implement a multi-phase generation algorithm in `MenuGenerator.generate()` (located at `menu_management/lib/menu/menu_generator.dart`).

### Phase 1: Separate Breakfast and Meal Generation
- Breakfasts are generated separately from lunch/dinner meals.
- Available recipes are shuffled with a configurable seed for variety.

### Phase 2: Recipe Selection Priority

For each meal time (sorted by available cooking time, least to most):

1. **Direct Assignment** (strictest): Find a recipe that fits the available cooking time, doesn't need storage, matches the strict meal time (lunch for lunch, dinner for dinner), and balances nutritional variety.

2. **Previous Cooking Opportunity** (fallback): If no direct recipe fits (e.g., 0 minutes available), look for earlier meals with cooking time available, select a storable recipe that can be cooked in advance, and assign the same recipe to both slots. The first occurrence gets yield > 0, subsequent uses get yield = 0.

3. **Nutritional Balance**: Tracks selection counts per nutritional type (carbs, proteins, vegetables). Prioritizes the least selected types. For already-selected recipes, prioritizes those used fewer times (up to a max repetition threshold).

4. **Yield Optimization**: After assignment, `copyWithUpdatedYields()` calculates correct yields:
   - Storable recipes: first occurrence gets yield = total appearances, subsequent get yield = 0 (eating leftovers)
   - Non-storable recipes: always yield = 1

### Key Variables
- `maxNumberOfTimesTheSameRecipeShouldBeUsed`: Based on percentage of meals that can be cooked at the spot (approx `totalMeals * percentageCanCook / 3.1`)
- `strictMealTime`: true for direct assignment (lunch recipes only for lunch); false for stored meals (either works)

### Recipe Filtering
- `includeInMenuGeneration` must be true
- Must fit configuration constraints (storage requirement, cooking time, meal time)
- Nutritional flags (carbs, proteins, vegetables) must match selection strategy

## Consequences

- Deterministic output for a given seed, allowing users to regenerate with different seeds for variety.
- Storable recipes enable "cook once, eat multiple times" optimization.
- Sorting by least available time first ensures the most constrained slots are filled first.
- Nutritional balance is best-effort, not guaranteed (depends on recipe library diversity).
