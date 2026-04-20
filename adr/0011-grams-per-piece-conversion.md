# ADR 0011: Grams-Per-Piece Conversion for Piece-Based Ingredients

## Context

Recipes use `Unit.pieces` for ingredients like garlic chunks, carrots, and deli meat slices. However, many of these ingredients only have weight-based (grams) store products. Without a way to convert between pieces and grams:

- The shopping list cannot calculate how many packs to buy (a pieces quantity does not match the product's grams unit, so the product row is hidden entirely).
- The owned-amount conversion in the shopping page returns 0 when crossing between pieces and grams.
- The waste optimizer cannot meaningfully compare pieces usage against gram-based products.

The existing `density` field on `Ingredient` bridges volume and weight but deliberately returns null for pieces. A parallel mechanism was needed for the pieces-to-weight bridge.

## Decision

Add an optional `gramsPerPiece` field (double?) to the `Ingredient` model, representing the average weight in grams of one "piece" as used in recipes. This mirrors how `density` bridges volume and weight:

| Field | Bridges | Example |
|-------|---------|---------|
| `density` | volume (cl, tbsp, tsp) to grams | 1.05 for yogurt |
| `gramsPerPiece` | pieces to grams | 5 for garlic chunks, 80 for carrot |

The field plugs into the existing `toGrams()` and `fromGrams()` methods on `Ingredient`:

- `toGrams(pieces)` returns `amount * gramsPerPiece` (previously returned null)
- `fromGrams(grams, pieces)` returns `grams / gramsPerPiece` (previously returned null)

Both methods guard against null and zero values.

The quantity normalizer (`quantity_normalizer.dart`) conditionally converts pieces to grams during shopping list normalization when two conditions are met:

1. `gramsPerPiece` is set and greater than zero
2. The ingredient has no product with `unit == Unit.pieces`

The second condition prevents unwanted conversion for ingredients like eggs or potatoes that are sold by the piece and should stay in pieces on the shopping list. When a pieces-based product exists, the pieces quantity already matches the product unit and pack calculations work correctly.

The field is persisted in `.tsr` files via Freezed JSON serialization with `@JsonKey(includeIfNull: false)`, so old files without the field load with null (backward compatible).

## Consequences

- Shopping list product rows now appear for ingredients where recipes use pieces but products are in grams (e.g., "Ajo troceado": 4 pieces becomes 20g, matching the 150g product).
- Owned-amount conversion between pieces and grams works through the existing `_ownedInUnit` pipeline with no additional changes to the shopping page.
- The waste optimizer receives already-normalized gram quantities and produces correct recommendations.
- Ingredients with pieces-based products (e.g., Patata, Calabacin with pieces product) are unaffected: pieces stay as pieces.
- The UI exposes the field in the ingredient name editor dialog alongside the existing density field.
- No format version bump needed: old `.tsr` files without `gramsPerPiece` deserialize correctly with null default.
