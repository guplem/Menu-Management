# ADR 0014: Multi-Trip Shopping Planner for Freshness-Aware Copy Output

## Context

Until now the shopping list assumed a single shopping trip the day before menu day 0 (see ADR 0010). For multi-week menus this forces the user to either shop once and accept that fresh items in week 2 or 3 will already be expired, or shop multiple times manually and split the list themselves. Neither is great: the first wastes food, the second wastes time figuring out which item belongs to which trip.

We want a way for the user to optionally turn on "multi-trip mode" so the copy-to-clipboard output is split into one section per trip, with each section containing only what should be bought on that trip. Implicit goals: (a) minimize the number of trips so the user does not shop more than necessary, and (b) make sure no item appears on a trip that is too early for its `shelfLifeDaysClosed`, so nothing the user buys is already past its sealed shelf life when used.

## Decision

Add `lib/shopping/multi_trip_planner.dart` that exposes a pure function `planShoppingTrips` returning `List<ShoppingTrip>`, plus a UI toggle in `ShoppingPage`'s `AppBar` that switches between single-list and sectioned copy output.

### Trip schedule

A trip with `weekIndex = N` happens on absolute day `N * 7 - 1`, i.e., the day before week N+1 starts. Trip 0 corresponds to the existing "day before menu starts" assumption. There is no finer granularity; the planner does not consider mid-week trips. This matches how users actually shop and keeps the algorithm simple.

### Algorithm: greedy interval point cover

For each cooking event (per ingredient, per unit, per day) the planner computes a valid trip window `[earliestWeek, latestWeek]`:

- `latestWeek = (dayIndex + 1) ~/ 7` (the trip is on or before the cooking day).
- For perishable events (matching product has a non-null `shelfLifeDaysClosed = S`), `earliestWeek` is the smallest W with `W * 7 - 1 + S > dayIndex`, i.e., trip W still gets the item fresh when it is used.
- For non-perishable events (no matching product or null shelf life), `earliestWeek = 0`.

Perishable events are sorted by `latestWeek` ascending and processed greedily: reuse a previously chosen trip if it falls within the event's window, otherwise add the event's `latestWeek` as a new chosen trip. This is the textbook minimum interval point cover.

Non-perishable events are processed afterwards: each is placed on the earliest already-chosen trip that is on or before the event's `latestWeek`. If none exists (e.g., no perishables at all), trip 0 is added. This biases non-perishables toward early purchase rather than late, which matches user expectation (buy the pantry stuff up front).

When no trip can possibly serve a perishable event fresh (very short shelf life relative to cooking day), the planner falls back to the latest trip on or before the event day. The existing menu expiry warning (ADR 0010) continues to surface this to the user; the shopping list does not silently drop the item.

### Per-event shelf life lookup

Shelf life is read from the same-unit product variants of the ingredient. ADR 0015 changes this from a first-match lookup to an any-match across same-unit variants: if any variant has `shelfLifeDaysClosed = null` the ingredient is treated as non-perishable, otherwise the planner uses the maximum `shelfLifeDaysClosed` across the matching variants. This mirrors the menu warning's "warn only if every variant is past sealed life" policy and lets a long-life variant consolidate trips that would otherwise be split. The original first-match wording is kept here for historical context.

### Owned amounts

`planShoppingTrips` accepts an optional `ownedAmounts: Map<String, List<Quantity>>`. Owned amounts are consumed against the matching-unit events in chronological order before trips are computed. Owned amounts in a unit that no event uses are ignored (no cross-unit conversion in the planner; the caller is responsible for converting if desired).

### UI

`ShoppingPage` originally exposed a single boolean `_splitByFreshness` and an `IconButton` action in the AppBar: when ON, a small banner under the AppBar reported the trip count and weeks involved, and the floating copy button emitted a sectioned text output (`Week 1\n--------\n...\n\nWeek 2\n--------\n...`). When OFF, the copy output was a flat list ignoring shelf life.

ADR 0015 supersedes this UI: the OFF mode (flat list, ignore shelf life) was dropped, and the toggle was renamed `_useFreezerStrategy`. Both modes now produce sectioned, freshness-aware copy output. OFF is the original ON behavior (multi-trip, no freezing). ON is the new freezer-aware mode where freezable items ride trip 0 with a `(freeze on arrival)` suffix and only non-freezable perishables can force later trips. The on-screen list is still not sectioned; the toggle is still purely a copy-format switch plus a short status banner.

## Consequences

- The user can now produce a "buy these things on this trip" plan with one click, without having to mentally split the menu themselves.
- The greedy is optimal for minimum trip count under the week-boundary trip schedule: standard interval point cover. There is no smaller set of trips that respects every event's freshness window.
- Trips are weekly-only by construction. If the user has a real-world cadence like "I shop on Wednesday and Saturday", the planner cannot match it. Adding configurable trip days would mean exposing trip schedules in the UI; deferred until requested.
- The planner originally used the first-matching-unit product for shelf life. ADR 0015 promoted this to an any-match: the longest sealed shelf life among same-unit variants drives trip planning, and any freezable variant makes the ingredient freezable for the freezer-aware mode. The shopping page's pack-display code (`products.first`) is unaffected; only the planner's shelf-life and freezable lookups changed.
- Non-perishables defaulting to trip 0 means a menu of only non-perishables produces a single trip 0, matching the prior single-trip behavior exactly.
- Owned amounts are still tracked at the ingredient level (one number, one selected unit), not per-trip. The planner subtracts owned from earliest events first, which usually means owned reduces what is bought on the earliest trip. There is no way today for the user to say "I have 100g of X but I want to use it on trip 2". If this comes up we can add per-event owned overrides.
- The on-screen list does not visually sectionize when the toggle is on. The banner under the AppBar is the only on-screen feedback besides the copy output. If users want section headers on screen we can iterate on the per-ingredient widget without changing the planner.
- The `single-shopping-trip` assumption in ADR 0010's menu expiry warning is unchanged: that warning still assumes one purchase the day before menu day 0. Multi-trip mode is a property of the shopping list copy, not of the menu warning. Reconciling them (warning aware of trips) is possible later but not part of this change. The freeze-aware single-trip mode is documented in ADR 0015 and likewise does not change the menu warning's single-trip assumption.
