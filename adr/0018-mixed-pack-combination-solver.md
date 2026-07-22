# ADR 0018: Mixed-Pack Combination Solver for Shopping Recommendations

## Context

When an ingredient has several pack sizes (see ADR 0010), `rankProducts` (`lib/shopping/waste_optimizer.dart`) scored each product on its own and the UI marked the single lowest-waste product as the "best option". It never combined products. This wastes food whenever no single pack size fits the need well but a mix does. Two cases matter:

- **Pack granularity.** Need 600 g with 250 g and 400 g packs: three 250 g packs waste 150 g, two 400 g packs waste 200 g, but one 250 g + one 400 g wastes only 50 g.
- **Per cooking event.** The same weekly total split across cooking days far apart (beyond the opened shelf life) cannot be served from one big pack, because the leftover expires between events. Buying a small pack for the small event and a large pack for the large event avoids both the expiry and the over-buy.

Issue #3 proposed this combination solver but only the per-product ranking shipped. Issue #26 asks for it: recommend buying a mix of products for one ingredient when that covers the need with less total waste, based on the per-cooking-event amounts, and fall back to a single product when one already fits best.

## Decision

Add `recommendCombination` to `lib/shopping/waste_optimizer.dart` alongside the existing `rankProducts` (which is kept for the per-product "best option" chips). It returns a `CombinationRecommendation`: a list of `PackSelection`s (product + pack count) plus the over-buy and expiry waste of the chosen mix.

### Objective

For a fixed set of purchased packs, when the need is met, `totalWaste = totalBought - totalNeeded` and splits into over-buy (never-used surplus) and expiry (opened food past its opened shelf life before use). So the solver minimizes total bought subject to covering every cooking event with non-expired food. The over-buy vs expiry split is derived for display; it does not change the ranking.

### Bounded, deterministic search

The solver enumerates pack-count vectors `(n_1, ..., n_k)` for the `k` same-unit products, with each `n_i` from 0 to that product's solo pack count (`_simulateProduct(...).packsNeeded`, which already accounts for expiry). Buying more of one product than would cover the whole need alone is never less wasteful, so that is a safe upper bound. The search is the Cartesian product of those ranges. When the number of vectors would exceed `_maxCombinationVectors` (20000), the search is skipped and the best single product from `rankProducts` is returned. Products are sorted internally (ascending pack size, then link, then unit) so the result never depends on the caller's input order.

### Per-combination simulation

Each candidate is scored by `_simulateCombination`, a generalization of the single-product `_simulateProduct` to a heterogeneous container pool. Each pack contributes `itemsPerPack` containers of `quantityPerItem`. Events are processed in day order: open containers past their opened shelf life expire; the remaining need is consumed soonest-expiry-first; new containers are opened as needed, choosing the smallest container that fully covers the remaining need (else the largest available), which keeps leftover that must survive to a later event as small as possible. Both rules are deterministic, and for a single product the simulation reduces to `_simulateProduct`. A candidate is infeasible when the pool runs out before covering an event.

### Tie-break

Best is chosen by: (1) lowest total waste, (2) fewest distinct products (so a single product beats an equal-waste mix, satisfying the fallback requirement), (3) fewest total packs, (4) lexicographically smaller count vector. All deterministic.

### Surfacing

- **Card UI** (`ShoppingIngredient`): computed per required unit with the full need and full events (same inputs as the "best option" chips), so the recommended mix reflects the individual cooking events. A "Best value" banner is shown only for real mixes (2+ products); single-product picks stay conveyed by the existing chip.
- **Copy output** (`_appendIngredientLines` in `shopping_page.dart`): the per-product independent listing was replaced by the recommended combination's pack lines (`combinationPackLines`). Copy runs per trip and each trip is already a shelf-life-safe bucket (ADR 0014), so the copy passes empty events: within a trip the mix only needs to minimize pack-granularity over-buy.

**Rejected alternative:** an event-aware combination per trip in the copy. The multi-trip planner (ADR 0014) aggregates each trip to a single amount per unit and does not expose per-event breakdowns per trip. Reconstructing them would duplicate the planner's owned-amount and shelf-life logic. Since the trip is already expiry-safe by construction, a whole-trip amount with pure over-buy optimization is sufficient there; the per-event benefit is delivered on the ingredient card, which sees the full timeline.

## Consequences

- The list can now recommend "buy N of pack A and M of pack B" when it lowers waste, and falls back to a single product when one already fits best. The copy output reflects the recommended combination.
- The search is exhaustive within its bound, so within the bound the chosen mix is optimal for the modeled waste. Above the bound it degrades gracefully to the previous single-product recommendation.
- The container-opening rule is a deterministic heuristic, not a proof of minimum expiry for every fixed purchase. Because the outer search covers all pack-count vectors, a slightly suboptimal expiry estimate for one vector rarely changes the final pick; the reported waste for the chosen mix stays consistent with `_simulateProduct`.
- The card recommendation uses the whole-menu timeline while the copy is sectioned per trip (ADR 0014), so the two can differ for multi-week menus. This mirrors the existing design, where the card shows a whole-menu "best option" and the copy splits per trip.
- `rankProducts` is unchanged and still drives the per-product chips; the combination solver is additive. Owned-amount handling is unchanged: the card uses the full need (like the chips) and the copy uses the planner's owned-reduced per-trip amounts.
