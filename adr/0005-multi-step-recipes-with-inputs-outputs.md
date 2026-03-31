# ADR 0005: Multi-Step Recipes with Inputs/Outputs

## Context

Some recipes have intermediate steps where the output of one instruction feeds into another (e.g., dicing onions in step 1, then using "diced onions" in step 2's sauce). Without explicit tracking, users would have to mentally connect steps, and the UI couldn't validate that instructions reference valid prior outputs.

We wanted recipes to feel like a directed graph of steps rather than a flat list, while keeping the data model simple enough for JSON serialization.

## Decision

Introduce a `Result` model representing an intermediate cooking output. Each `Instruction` can declare:
- **outputs**: a list of `Result` objects it produces (e.g., `Result("diced-aromatics", "Diced onions and garlic")`)
- **inputs**: a list of result IDs it consumes from previous instructions

This creates an explicit dependency chain between instructions within a single recipe.

### How it works

**Example: Pasta Bolognese**
1. Instruction 1: Dice onions and garlic -> outputs: `["diced-aromatics"]`
2. Instruction 2: Cook sauce with ground beef -> inputs: `["diced-aromatics"]`, outputs: `["bolognese-sauce"]`
3. Instruction 3: Cook pasta -> outputs: `["cooked-pasta"]`
4. Instruction 4: Combine and serve -> inputs: `["bolognese-sauce", "cooked-pasta"]`

### Validation rules
- An instruction can only reference outputs from **previous** instructions (enforced by `RecipesProvider.getRecipeInputsAvailability()`)
- An instruction cannot reference its own outputs (no circular dependencies)
- The UI only shows available inputs when editing an instruction

### Cook Mode integration
- In Play Recipe mode, input references appear visually distinct (tertiary color)
- Tapping an input opens a dialog showing the source step summary with a button to jump to it

## Consequences

- Recipes can model real cooking workflows where parallel and sequential steps coexist.
- The ordering of instructions matters and is enforced by the input/output dependency chain.
- The `Result` model is minimal (id + display name), keeping serialization lightweight.
- Instructions without inputs/outputs work exactly as before, so existing simple recipes are unaffected.
