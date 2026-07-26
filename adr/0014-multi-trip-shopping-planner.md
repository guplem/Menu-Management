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

`planShoppingTrips` accepts an optional `ownedAmounts: Map<String, OwnedStock>`, where `OwnedStock` (in `owned_amount.dart`) has two shapes (see ADR 0011 and issue #24):

- **Single-form** (`OwnedStock(amount, unit)`): one amount plus one selected unit (or null for "packs"). Used for ingredients with no products.
- **Per-product** (`OwnedStock.perProduct(countsByProductIndex)`): one owned count per product of the ingredient. The global owned amount is summed from each product's count times its pack quantity. Used for ingredients that have products, so the user can say "I have 3 of product A and 5 of product B".

Both shapes resolve to an amount in a target unit through `OwnedStock.amountInUnit(ingredient, targetUnit)`. Single-form delegates to the shared `ownedAmountInUnit`; per-product sums each product's contribution via `productOwnedAmountInUnit` (count times pack quantity, converted with the ingredient's `toGrams`/`fromGrams`). `ownedAmountInUnit` handles same-unit, cross-unit (grams <-> pieces via `gramsPerPiece`, weight <-> volume via `density`), and "packs" mode (the product whose unit matches the target unit).

Both the planner and the on-screen list then draw the stock down through the shared `OwnedStockConsumer` (in `owned_amount.dart`). The consumer takes the whole `OwnedStock`, so both shapes feed the same single pool: it reads the stock's grams total via `OwnedStock.amountInUnit(ingredient, grams)` (for per-product, the summed global grams from every owned product) into one grams pool, then consumes that pool across the ingredient's needs, one need at a time, in chronological order. A need whose unit has no grams path, or an owned stock with no grams path at all (for example owned pieces with no `gramsPerPiece`), falls back to a per-unit subtraction that likewise reads from `OwnedStock.amountInUnit`. Because both callers use the same consumer over the same `OwnedStock`, the copied trip amounts always equal the on-screen "Need" amounts. The on-screen list builds the same stock via `_ownedStockFor` in `shopping_page.dart` and runs it through `computeRemainingQuantities`, which is the same `OwnedStockConsumer`, so per-product owned is subtracted once, across units, exactly as the planner does. When no conversion path exists, nothing is subtracted.

Earlier this planner did no cross-unit conversion: it took owned as `Map<String, List<Quantity>>` and subtracted only when the owned unit exactly matched the event unit, and the shopping page converted "packs" using the ingredient's first product. That diverged from the on-screen list (which converted correctly), so the copied list could list a higher amount to buy than the page showed. Moving both to `ownedAmountInUnit` removed that divergence.

A later divergence came from converting the same owned stock into each unit independently. When one ingredient is needed in two units at once (for example grams in one recipe and pieces in another, with a pieces product so the normalizer keeps both), subtracting the full stock from each unit over-subtracts. On the page this only inflated how much was marked as owned; in the planner it zeroed every event and dropped the ingredient from the trip list entirely, so the copy was missing an ingredient the page still showed as needed. The single-grams-pool `OwnedStockConsumer` fixes both: it is the one source of truth for owned-stock subtraction, so a single stock is never subtracted more than once and the planner never drops an ingredient the page still needs.

### Matching the copied amounts to the on-screen list

The on-screen list normalizes units before display (`quantity_normalizer.dart`: pieces to grams via `gramsPerPiece`, volume to grams via `density`) and rounds each ingredient's total once. The planner instead works on the raw, per-day cooking timeline in the recipe's own units. Feeding the planner's raw per-trip amounts straight into the copied text made the copy diverge from the page in two ways: a different unit (planner "4 pieces" vs page "20 g"), and per-trip lines that rounded separately and summed to one more or less than the page total.

The copy no longer prints the planner's raw amounts. For each ingredient it takes the on-screen remaining (already normalized, owned-subtracted, and rounded) and calls `distributeRemainingAcrossTrips` (in `trip_amount_distributor.dart`), which spreads that remaining across the weeks the planner chose. Each week's share is weighted by that week's raw need expressed in grams (so pieces and volume compare on one scale), and a largest-remainder split keeps every per-trip line a whole number while guaranteeing the lines sum to exactly the on-screen amount, in the on-screen unit. The planner still owns trip assignment (which weeks, respecting shelf life); the distributor only decides how the page's number is split across those weeks. The on-screen per-trip pack split (`_tripPurchasesForProduct` in `shopping_ingredient.dart`) still rounds each trip's raw amount to compute packs; it agrees with the copy at pack granularity and is left unchanged.

### UI

`ShoppingPage` originally exposed a single boolean `_splitByFreshness` and an `IconButton` action in the AppBar: when ON, a small banner under the AppBar reported the trip count and weeks involved, and the floating copy button emitted a sectioned text output (`Week 1\n--------\n...\n\nWeek 2\n--------\n...`). When OFF, the copy output was a flat list ignoring shelf life.

ADR 0015 supersedes this UI: the OFF mode (flat list, ignore shelf life) was dropped, and the toggle was renamed `_useFreezerStrategy`. Both modes now produce sectioned, freshness-aware copy output. OFF is the original ON behavior (multi-trip, no freezing). ON is the new freezer-aware mode where freezable items ride trip 0 with a `(freeze on arrival)` suffix and only non-freezable perishables can force later trips. The on-screen list is still not sectioned; the toggle is still purely a copy-format switch plus a short status banner.

## Consequences

- The user can now produce a "buy these things on this trip" plan with one click, without having to mentally split the menu themselves.
- The greedy is optimal for minimum trip count under the week-boundary trip schedule: standard interval point cover. There is no smaller set of trips that respects every event's freshness window.
- Trips are weekly-only by construction. If the user has a real-world cadence like "I shop on Wednesday and Saturday", the planner cannot match it. Adding configurable trip days would mean exposing trip schedules in the UI; deferred until requested.
- The planner originally used the first-matching-unit product for shelf life. ADR 0015 promoted this to an any-match: the longest sealed shelf life among same-unit variants drives trip planning, and any freezable variant makes the ingredient freezable for the freezer-aware mode. The shopping page's pack-display code (`products.first`) is unaffected; only the planner's shelf-life and freezable lookups changed.
- Non-perishables defaulting to trip 0 means a menu of only non-perishables produces a single trip 0, matching the prior single-trip behavior exactly.
- The copied per-trip amounts always equal the on-screen list: same unit, and per-trip lines that sum to the on-screen total with no rounding drift. The planner picks the trips; `distributeRemainingAcrossTrips` splits the page's number across them. If the planner and page ever disagree on which weeks buy an ingredient, the page total still wins because the copy is derived from it.
- Owned amounts are tracked per product for ingredients that have products (one count per product), and as one number plus one selected unit for ingredients without products (see ADR 0011 and issue #24). They are not tracked per-trip. The planner subtracts the summed global owned amount from earliest events first, which usually means owned reduces what is bought on the earliest trip. There is no way today for the user to say "I have 100g of X but I want to use it on trip 2". If this comes up we can add per-event owned overrides.
- The on-screen list does not visually sectionize when the toggle is on. The banner under the AppBar is the only on-screen feedback besides the copy output. If users want section headers on screen we can iterate on the per-ingredient widget without changing the planner.
- The `single-shopping-trip` assumption in ADR 0010's menu expiry warning is unchanged: that warning still assumes one purchase the day before menu day 0. Multi-trip mode is a property of the shopping list copy, not of the menu warning. Reconciling them (warning aware of trips) is possible later but not part of this change. The freeze-aware single-trip mode is documented in ADR 0015 and likewise does not change the menu warning's single-trip assumption.
