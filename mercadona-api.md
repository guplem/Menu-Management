# Mercadona API Reference (for AI Agents)

This document explains how to use the Mercadona online store API to look up product data when adding or editing `Product` entries on ingredients.

## Base URL

```
https://tienda.mercadona.es/api/products/{product_id}/?wh=bcn1
```

Always append `?wh=bcn1` to target the Barcelona warehouse (the user's region: CP 08901, L'Hospitalet de Llobregat). Without it, the API defaults to a different warehouse and may return 404 for products that do exist locally.

Extract the product ID from a Mercadona URL:
```
https://tienda.mercadona.es/product/20559/some-slug  ->  ID = 20559
```

An alternative versioned endpoint also works:
```
https://tienda.mercadona.es/api/v1_1/products/{product_id}?wh=bcn1
```

## Region Availability

The API is **region-locked** by warehouse. The `wh` query parameter selects the warehouse. Use `wh=bcn1` for the user's region (Barcelona). Other known values: `mad1` (Madrid), `vlc1` (Valencia), `alc1` (Alicante).

If a product still returns 404 with `wh=bcn1`, it may genuinely be unavailable in the user's region. In that case, ask the user to confirm the product details manually.

To look up the warehouse code for any postal code:
```bash
curl -X PUT -H 'content-type: application/json' \
  --data '{"new_postal_code":"08901"}' \
  'https://tienda.mercadona.es/api/postal-codes/actions/change-pc/'
# Response header x-customer-wh contains the warehouse code (e.g. "bcn1")
```

## Key Fields in the Response

### `price_instructions` (most important for Product model mapping)

| Field | Type | Description |
|-------|------|-------------|
| `is_pack` | bool | `true` if the product is a multi-unit pack (e.g., pack of 6 cans) |
| `total_units` | int? | Number of items in the pack. Present for packs and some multi-item trays. `null` for single items. |
| `unit_name` | string? | Human-readable unit label: `"latas"`, `"bolsitas"`, `"ud."`, `"paquetes"`, `"sobres"`, etc. `null` for single items. |
| `pack_size` | double? | Weight/volume of each individual item within a pack (in `size_format` units). Only meaningful when `is_pack == true`. |
| `unit_size` | double | Total weight/volume of the entire product (in `size_format` units). |
| `size_format` | string | `"kg"` or `"l"` (kilograms or liters). |

### Other useful fields

| Field | Type | Description |
|-------|------|-------------|
| `packaging` | string? | `"Pieza"` (single item), `"Pack-N"` (multi-pack), `"Bandeja"` (tray), `"Bote"` (jar/can), `"Brik"` (brick), `"Paquete"` (package), etc. |
| `share_url` | string | Canonical product URL for the `link` field in the Product model. |
| `details.storage_instructions` | string | Look for "consumir en N dias" to derive `shelfLifeDaysOpened` (days after opening). If the page also lists a separate sealed shelf life, set `shelfLifeDaysClosed` from that. |
| `is_bulk` | bool | `true` for items sold by weight (e.g., fresh produce sold per piece). |

## Mapping API Response to Product Model Fields

```
Product(
  link:            share_url
  itemsPerPack:    total_units ?? 1
  quantityPerItem: if is_pack -> pack_size * 1000 (kg->g) or pack_size * 100 (l->cl)
                   else       -> unit_size * 1000 (kg->g) or unit_size * 100 (l->cl)
  unit:            "grams" if size_format == "kg"
                   "centiliters" if size_format == "l"
                   "pieces" if the product is countable (see below)
  shelfLifeDaysOpened: parse from details.storage_instructions (days after opening), null if not found
  shelfLifeDaysClosed: parse from details.storage_instructions when a separate sealed
                       shelf life is given, null if indefinite when sealed
)
```

**Verification**: `itemsPerPack * quantityPerItem` should equal `unit_size * 1000` (for kg) or `unit_size * 100` (for l).

## Countable Items (pieces unit)

Some ingredients are used in recipes by count ("3 pieces") rather than by weight. These need an **additional** Product entry with `unit: pieces` alongside the existing grams/centiliters product.

**Exception:** self-contained meal kits always bought and cooked whole (e.g. an instant yakisoba packet) only need the `pieces` product; skip the grams one.

A pieces product looks like:
```json
{
  "link": "<same product URL>",
  "itemsPerPack": <number of discrete items in the pack>,
  "quantityPerItem": 1.0,
  "unit": "pieces"
}
```

### How to determine items per pack

1. **API has `total_units`**: Use that value directly. Examples: canned tuna pack-6 (`total_units: 6`), corn pack-3 (`total_units: 3`).
2. **`packaging == "Pieza"`**: Single item, `itemsPerPack: 1`. Examples: banana, zucchini.
3. **`packaging == "Bote"` or `"Brik"`**: Single container, `itemsPerPack: 1`. Examples: canned chickpeas, chicken broth.
4. **`packaging == "Bandeja"` (tray) without `total_units`**: Variable piece count. The API does not report how many fillets/thighs/etc. are in a tray. Ask the user to confirm.
5. **Bulk/uncountable items**: Do NOT add pieces products for things like chopped garlic, sliced deli meat, cherry tomatoes, olives, nuggets, sliced bread, shredded cheese, etc.

### Identifying countable items

**Countable** (should have pieces product): individual fruits/vegetables sold per piece, canned goods, frozen pizzas, burger patties, individual sachets/packets, whole poultry pieces in trays.

**Not countable** (skip): sliced/chopped/shredded items, bulk items in bags (rice, pasta), small items in large quantities (cherry tomatoes, olives, nuggets), spices, liquids.

## Example API Calls

Single vegetable (pieza):
```
GET https://tienda.mercadona.es/api/products/69338/
-> packaging: "Pieza", total_units: null, unit_size: 0.38 kg
-> Product: itemsPerPack=1, quantityPerItem=380g, unit=grams
-> Pieces product: itemsPerPack=1, quantityPerItem=1, unit=pieces
```

Multi-pack (canned tuna):
```
GET https://tienda.mercadona.es/api/products/18002/
-> is_pack: true, total_units: 6, pack_size: 0.06 kg, unit_name: "latas"
-> Product: itemsPerPack=6, quantityPerItem=60g, unit=grams
-> Pieces product: itemsPerPack=6, quantityPerItem=1, unit=pieces
```

Single container (canned chickpeas):
```
GET https://tienda.mercadona.es/api/products/26110/
-> packaging: "Bote", total_units: null, unit_size: 0.42 kg
-> Product: itemsPerPack=1, quantityPerItem=420g, unit=grams
-> Pieces product: itemsPerPack=1, quantityPerItem=1, unit=pieces
```
