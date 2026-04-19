# ADR 0010: Product Entity for Pack-Based Shopping List Display

## Context

The shopping list previously displayed raw required amounts (e.g., "500 g"). This is useful for cooking but not for shopping: stores sell items in fixed pack sizes, and shoppers need to know how many packs to buy, not how many grams. There was no way to record store product data (pack size, quantity per item, a link to the product page) against an ingredient.

A second goal was to keep this data optional. Not every ingredient has a known store product, and the shopping list should degrade gracefully to raw amounts when no product is attached.

Some ingredients come in multiple pack sizes (e.g., canned corn: 3x70g small vs 3x140g large). The model supports linking multiple products to a single ingredient to enable future smart shopping recommendations (see GitHub issue #3).

## Decision

Introduce a `Product` Freezed model stored as a `List<Product>` on `Ingredient` (defaulting to an empty list). `Product` stores four fields: `link` (store URL), `itemsPerPack`, `quantityPerItem`, and `unit`. It exposes derived methods:

- `totalQuantityPerPack`: `itemsPerPack * quantityPerItem`
- `packsNeeded(double requiredAmount)`: `ceil(requiredAmount / totalQuantityPerPack)`
- `formatQuantityForDisplay(double requiredAmount, Unit requiredUnit)`: returns "N packs (X unit)" when units match, or "amount unit" as fallback

The model lives at `lib/ingredients/models/product.dart`. Because `Product` is a nested Freezed model inside `Ingredient`, it serializes automatically as a nested JSON array in `.tsr` files. No changes to the persistence layer were required.

The shopping list (both the on-screen widget and the clipboard export) uses `ingredient.products.first.formatQuantityForDisplay(...)` to conditionally format amounts as "N packs (X unit)" when at least one product is attached and its unit matches the required quantity's unit. When no products are attached, the display falls back to the raw amount. This unit-matching guard prevents nonsensical pack counts when a recipe uses a different unit than the product's unit (e.g., recipe calls for grams, product is measured in centiliters). For piece-based ingredients, the product must use `unit == Unit.pieces` so that recipe quantities in pieces match the product's unit and produce correct pack counts.

Product data is edited via a `ProductEditor` dialog accessible from the ingredients list, indicated by a highlighted shopping bag icon when at least one product is set. The editor supports adding, editing, and removing multiple products per ingredient.

## Consequences

- Shoppers see actionable pack counts in the shopping list for any ingredient with a product attached.
- The raw-amount fallback means existing ingredients without products continue to work without migration.
- `Product` data is persisted inside the existing `.tsr` format with no format version bump; old `.tsr` files without product data load correctly because `products` defaults to an empty list.
- Pack counts are rounded up (ceiling) so the shopper always buys enough.
- The shopping list currently uses only the first product for display. Future work (issue #3) will use multiple products to recommend optimal pack-size combinations per cooking event.
- The shopping list does not track owned packs -- it continues to track owned quantities in the ingredient's native unit. The pack display is presentation-only.
