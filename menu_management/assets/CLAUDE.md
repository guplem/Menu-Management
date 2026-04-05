# Recipe Data Guidelines

Guidance for editing `RecipeBook.tsr` and `DefaultMenu.tsm`. Think like a pragmatic chef: minimize shopping list size, reduce prep time, avoid waste. These are defaults, not absolutes -- the user may have good reasons to override any of them, so ask when in doubt.

## Before adding any ingredient

1. **Search the existing ingredient list first.** If something similar already exists, suggest using it.
2. **Flag single-use ingredients.** If a new product would only appear in one recipe, mention it to the user. They might prefer an existing substitute, or they might want it anyway.
3. **Check if a frozen or canned version already exists** in the ingredient list before adding a fresh variant. Suggest the shelf-stable option for cooked dishes, but the user may prefer fresh.

## Frozen and shelf-stable preferences

- **Cooked dishes**: Suggest frozen vegetables and canned alternatives when available. They cook well and last longer.
- **Raw/cold dishes** (salads, dips): Fresh usually makes more sense here.
- **Ground spices over fresh aromatics**: When a recipe uses a tiny amount of something like ginger or lemongrass, suggest the ground/dried version. A 200g fresh pack for 2.5g of use is wasteful.
- **Instant rice as side dish**: When rice just accompanies a main, suggest Arroz Instantaneo. Regular rice makes more sense when it's central to the dish (paella, arroz con tomate).

## Keep the shopping list small

- **Suggest consolidating product variants.** Before adding another pasta shape, cheese type, or sauce, point out what's already available.
- **Suggest reusing sauces and condiments across recipes.** If Tomate Triturado works in the new recipe and is already used elsewhere, propose it.
- **Suggest substituting rather than accumulating.** If the recipe needs mild heat, check if Pimenton/Paprika (already in the list) could work before introducing a new product.

## Data quality

- **Units must match the ingredient type.** Meat and produce in grams or pieces, liquids in centiliters, spices in teaspoons/tablespoons.
- **Quantities must be realistic.** Dried spices are typically 0.1-2 teaspoons per serving, not hundreds of grams.
- **Step descriptions must match ingredients.** If a step uses milk, don't say "yogurt". No placeholder text.
- **ref_name must match the current ingredient name.** After renaming an ingredient, update all ref_name references.

## Proactive auditing

When touching recipe data for any reason, scan nearby recipes for issues and flag them to the user. Common problems:

- **Wrong units** (pieces vs grams, grams vs centiliters).
- **Absurd quantities** (150g of dried parsley, 0.001 pieces of something).
- **Copy-paste leftovers** in step descriptions (ingredient names that don't match what the step actually uses, placeholder text).
- **Orphaned references** (ingredient IDs that don't exist, output IDs referenced as inputs that were deleted).
- **Steps that could be merged or simplified** (e.g., a "grate tomato" step followed by "add grated tomato" could become one step using tomate triturado).
- **Fresh ingredients used in tiny amounts** in a single recipe that could be a pantry spice or dropped.

Always propose fixes to the user rather than silently changing things.

## Product links

- **Mercadona is the primary store.** Suggest Mercadona links first. Other stores are fine if the product isn't available there.
- **Include itemsPerPack, quantityPerItem, and unit** for every product entry.
