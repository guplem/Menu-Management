# ADR 0015: Freezable Products and Freezer-Aware Single-Trip Mode

## Context

ADR 0014 introduced a multi-trip shopping planner that splits the copy output by week so nothing is past its sealed shelf life when used. That solved the freshness problem at the cost of extra trips: a three-week menu with a couple of fresh meats can force three separate shopping runs.

Many products that have short sealed shelf life can be frozen on arrival and survive the whole menu (raw meat, fish, bread). Real users routinely buy a week's worth of perishables, freeze them, and thaw as needed. The planner had no way to model this. The menu page expiry warning (ADR 0010) had the same blind spot: it raised a red flag for any meal whose ingredients were past sealed shelf life, even when the user could trivially cover the gap by freezing.

We want two things:

- A way to mark on a per-product basis whether it can be frozen on arrival.
- A second shopping mode that uses this flag to consolidate trips. Freezable items ride the first trip and get an explicit "freeze on arrival" annotation; only non-freezable perishables that exceed sealed shelf life force later trips.

We also want the menu page warning to express this distinction visually: an impossible meal (no variant survives, none is freezable) is not the same kind of problem as a meal that just needs the user to freeze something.

## Decision

### Model

Add `@Default(false) bool canBeFrozen` to `Product` (`lib/ingredients/models/product.dart`). The field is non-nullable; old `.tsr` files without the key load with `false` via Freezed's `@Default`. No migration shim is needed (only renamed keys need shims). Treating `canBeFrozen = true` as "indefinite shelf life when frozen" is intentional: freezers do have limits in the real world, but tracking a separate frozen-shelf-life duration adds a field per product without changing user behavior in the typical multi-week-menu range. We can revisit if it becomes a problem.

The product editor (`lib/ingredients/widgets/product_editor.dart`) gains a `Switch` row labeled "Can be frozen", consistent with the existing boolean toggles elsewhere in the app.

### Menu page expiry warning: two severities

`MealExpiryWarning` (`lib/menu/expiry_warnings.dart`) gains a `severity: MealExpirySeverity` field with two values:

- `impossible`: every product variant of the ingredient is past sealed shelf life by the meal day AND no variant is freezable. The user cannot get fresh ingredients to this meal under the single-shopping-trip assumption.
- `freezeRequired`: every variant is past sealed shelf life, but at least one variant is freezable. The user can still buy on day -1 and freeze on arrival.

The fire condition itself is unchanged: a warning still fires only when every variant is past `shelfLifeDaysClosed`. What changes is how the warning is rendered. `menu_page.dart` now renders:

- Red `Icons.warning_rounded` (existing color: `colorScheme.error`) when at least one warning on the meal is `impossible`. The tooltip lists impossible ingredients first, then freeze-required ingredients separately if any exist.
- Blue `Icons.ac_unit` (Material snowflake, `Colors.blue.shade400`) when every warning on the meal is `freezeRequired`. The tooltip names the ingredients with "Freeze on arrival to use it for this meal."
- Nothing when no warnings fire (today's behavior).

Red trumps blue: a meal with one impossible ingredient and one freeze-required ingredient shows red, because the impossible one blocks the meal. The blue is only meaningful when freezing alone resolves the problem.

### Shopping list: replacement of the freshness toggle

The previous shopping page toggle (`_ensureFreshness`) had two states: off = single flat list ignoring shelf life, on = multi-trip splitting by sealed shelf life. The "ignore shelf life" mode is dropped entirely. The new toggle is labeled **"Try to make one trip"** in the AppBar (internal flag `_useFreezerStrategy`). The two states are:

- **Off (Multi-trip mode)**: identical to ADR 0014's "on" behavior. The planner picks a minimum set of weekly trips so every event is within sealed shelf life. Freezing flags are ignored. Tooltip: "shop multiple times so nothing expires before cooking".
- **On (One-trip mode)**: every event whose matching product is freezable (any-match across same-unit variants) is treated as non-perishable for trip assignment AND pinned to trip 0. Such an event is also tagged `freezeOnArrival = true` when its sealed shelf life would not have covered the gap from trip 0 to the cooking day (i.e. the user actually has to freeze it). Non-freezable perishables continue to flow through the original interval-cover algorithm and may still force later trips when their shelf life is exceeded. Tooltip: "shop once and freeze items that would otherwise expire".

The copy output (and the on-screen banner) reflect the active mode and are sectioned by trip in both cases. When `freezeOnArrival = true` for an aggregated `TripItem`, the corresponding line gets a `(freeze on arrival)` suffix.

### Planner internals

`planShoppingTrips` gains an optional `bool assumeFreezerForFreezable = false` parameter. `TripItem` gains `final bool freezeOnArrival` (defaulting to `false`).

Inside `_buildPlanEvents`, the planner reads shelf life and the freezable flag using **any-match across same-unit variants** instead of first-match. If any same-unit variant has `shelfLifeDaysClosed = null`, the ingredient is treated as non-perishable; otherwise the maximum `shelfLifeDaysClosed` across same-unit variants is used. The freezable flag is `true` if any same-unit variant has `canBeFrozen` set. This supersedes the deferred decision in ADR 0014 and gives the planner the same any-match semantics that the menu warning already uses (`expiry_warnings.dart`): if any variant survives sealed, no warning fires and no late trip is forced; if any variant can be frozen, freezing logic applies.

When `assumeFreezerForFreezable` is true and the matching set is freezable, the event's `effectiveShelfLifeDaysClosed` becomes `null` (treated as non-perishable for the rest of the algorithm) and an internal `requiresFreezing` flag is set when `event.dayIndex + 1 >= shelfLifeDaysClosed`. Events with `requiresFreezing = true` are pinned to trip 0 in a dedicated phase between the perishable greedy and the non-perishable ride-along, ensuring they never end up on a later trip just because some other event forced one.

Aggregation collapses events with the same `(ingredient, unit, trip)` and OR-combines their `requiresFreezing` flags into the resulting `TripItem.freezeOnArrival`.

## Consequences

- Marking products as freezable is a manual, per-product action. Existing data loads with `canBeFrozen = false` everywhere; the user upgrades coverage incrementally. Mass pre-population of the bundled `RecipeBook.tsr` was deliberately skipped to keep the data change scoped to user choice.
- The "ignore shelf life" copy mode is gone. Users who previously relied on it now always see freshness-aware output. In a one-week menu with no perishable issues this still produces a single trip 0 with no "freeze on arrival" labels, so the visual difference is minimal.
- The freeze flag is binary: the planner cannot warn that you have left a freezable item in the freezer for too long. If freezer overuse becomes an issue we can add `shelfLifeDaysFrozen` later without breaking existing data.
- Red-trumps-blue tooltip rendering may surprise users when a meal has both impossible and freeze-required ingredients. The tooltip mentions the freeze-required ones explicitly so the user can still tell which ones are recoverable. A two-icon cluster (red + blue side by side) was considered but not adopted, to avoid clutter on small meal cards.
- Shopping copy lines for ingredients with multiple product variants get the `(freeze on arrival)` suffix at the ingredient header, not per pack-size sub-line. This matches the per-`TripItem` granularity of the planner output.
- The single-shopping-trip assumption documented in ADR 0010's last paragraph still holds for the menu warning's `mayBeExpiredOnDay` calculation. Freezing changes the warning's color, not when it fires.
- The planner's interval-cover greedy is unchanged for non-freezable perishables, so all existing ADR 0014 properties (minimum trips for the freshness constraint, weekly-only trip schedule, fallback to closest trip on or before the event when no trip can serve it fresh) remain true in the off mode.
