# ADR 0012: Replace canBeStored Boolean with maxStorageDays Integer

## Context

Recipes previously had a `bool canBeStored` field: either a recipe could be stored indefinitely within a week (true) or it had to be eaten the same day (false). This was too coarse -- in reality, different recipes have different shelf lives. A fresh salad might last one day while a stew could last a week.

Additionally, yield calculation was strictly per-week (see ADR 0008). A recipe cooked on Thursday could not carry over as leftovers to Monday of the following week, even though that is only 4 days apart and well within the shelf life of most cooked meals.

## Decision

Replace `bool canBeStored` with `int maxStorageDays` on `Recipe`:

- `0` = must eat the same day (equivalent to old `canBeStored: false`)
- `1` = today + tomorrow
- `6` = default for all previously storable recipes (covers a full week)
- `7` = maximum selectable in the UI (full week + 1 day, enabling cross-week carryover)

A derived getter `bool get canBeStored => maxStorageDays > 0` preserves readability in existing code that only needs the binary question.

### Yield calculation changes

`Menu.recalculateYields` (formerly `copyWithUpdatedYields`) now uses absolute day indices (`weekIndex * 7 + weekDay.value`) to determine whether a later occurrence of a recipe falls within the storage window of its cook day. If the distance exceeds `maxStorageDays`, a new cook event is created.

`MultiWeekMenu.copyWithUpdatedYields` chains this per-week, carrying over cook-day state from week N to week N+1 via `externalCookEvents`. This enables cross-week leftovers without flattening all weeks into a single data structure.

### Backward compatibility

`Recipe.fromJson` detects old JSON with `canBeStored` (boolean) and no `maxStorageDays`, and migrates: `true` becomes `6`, `false` becomes `0`. New JSON uses `maxStorageDays` directly.

## Consequences

- The bundled `RecipeBook.tsr` asset was migrated to `maxStorageDays`.
- Old `.tsr` files on disk are transparently migrated on load via `Recipe.fromJson`.
- New `.tsr` files are not readable by old app versions (forward-incompatible).
- The UI now shows a dropdown (0-7 days) instead of a toggle switch.
- Menu generation within a single week is largely unchanged; the generator does not yet specifically plan cross-week leftovers during assignment. Cross-week carryover is recognized in the yield recalculation step after generation.
- ADR 0004 and ADR 0008 were updated to reflect the new behavior.
