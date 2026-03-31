# ADR 0006: Cook Mode (Play Recipe)

## Context

Users need a hands-free way to follow a recipe while cooking. Reading a full recipe page with all instructions at once is impractical in a kitchen setting -- you want to focus on one step at a time, know when cooking timers are done, and scale quantities if cooking for more people.

## Decision

Implement a dedicated "Play Recipe" mode (`PlayRecipePage`) as a full-screen page pushed via `Navigator.push`, separate from the recipe editing/viewing flow.

### Why a separate pushed page instead of a tab or dialog
- Cook mode is a focused, immersive experience. It should take over the screen so the user isn't distracted by navigation rails or other UI.
- `Navigator.push` gives a natural back-button exit and lets us intercept the pop to warn about running timers.
- It receives the `Recipe` as a constructor parameter, making it stateless with respect to providers -- no risk of edits during cooking causing inconsistencies.

### Servings selector with quantity scaling
- Base recipe is always 1 serving. The user picks how many servings they want and all ingredient quantities scale proportionally.
- This was chosen over a "default servings" field on the recipe because it keeps the model simpler and the scaling is purely a presentation concern.

### Step-by-step navigation
- One instruction visible at a time, with previous/next preview cards for context.
- Progress indicator shows step N of M.
- Tapping a preview card navigates directly to that step.

### Input references from multi-step recipes
- Inputs from earlier steps appear in a visually distinct style (tertiary color).
- Tapping an input opens a dialog with the source step summary and a jump-to button, so the user can review what they prepared earlier without losing their place.

### In-memory timers (not persisted)
- Timers use `dart:async` `Timer.periodic` and live only in widget state.
- **Why not persist timers:** Cook mode is inherently a single-session activity. If the user leaves the page, the cooking session is over. Persisting timers would add complexity (background notifications, service workers) for a scenario that doesn't match real usage.
- A timer finishing plays an audio notification (`assets/sounds/timer.mp3`) via `audioplayers`.
- Multiple timers can run simultaneously across different steps. Active timers from other steps are visible below the current step's timer.
- Exit warning: if timers are running and the user tries to leave, a confirmation dialog warns that all timers will be cancelled.

### UI layout (top to bottom)
1. App bar with recipe name and servings selector
2. Progress indicator (step N of M)
3. Ingredients for the current step (inputs first, then regular ingredients)
4. Current instruction card with working/cooking time chips and outputs
5. Timer controls for the current step
6. Other active timers (from different steps)
7. Previous and next step preview cards

## Consequences

- No new dependencies beyond `audioplayers` (already used in the project).
- The feature is entirely self-contained in `play_recipe_page.dart` with no provider changes needed.
- Timer state is ephemeral -- closing the page loses all timers, which matches the real-world cooking session model.
- The `_StepTimer` helper class manages timer lifecycle (start, cancel, dispose) cleanly within the StatefulWidget.
