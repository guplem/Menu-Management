---
name: research-agents
description: Launch N parallel research agents that explore different improvement approaches, cross-pollinate ideas, and converge on a unified plan
argument-hint: "<target feature or area to improve>" [--agents=<N>] [--rounds=<N>] [--angles="angle1,angle2,..."]
---

# Multi-Agent Research Orchestrator

Launch parallel research agents that each explore a different angle of improvement for a feature or area, then iterate through rounds of cross-pollination until they converge on a unified recommendation.

## 1. Parse Arguments

- `TARGET`: The feature or area to improve (e.g., "menu generation algorithm", "recipe editor UX", "persistence format")
- `AGENTS`: Number of agents (default: 4, range: 2-6)
- `ROUNDS`: Number of rounds (default: 2)
- `ANGLES`: Comma-separated research angles (optional)

## 2. Explore the Target

Understand what's being improved:
- Identify ALL relevant source files
- Understand the current flow end-to-end
- Map external dependencies
- Note recent changes (`git log --oneline -20`)
- Identify the nature: UI feature? Algorithm? Data model? Architecture?

Produce a concise **Target Summary**.

## 3. Propose Research Angles (Interactive)

Propose angles tailored to this specific target. Present to the user with `AskUserQuestion` for confirmation.

Different systems call for different angles:

| System Type | Example Angles |
|-------------|---------------|
| Algorithm (menu gen) | Optimization quality, Performance, Configurability, Edge case handling |
| UI/UX (recipe editor) | Usability, Accessibility, State management, Animation/polish |
| Data model (Freezed) | Schema design, Serialization robustness, Migration strategy, Query patterns |
| Architecture | Testability, Separation of concerns, Scalability, Developer ergonomics |

Wait for user confirmation before proceeding.

## 4. Create Planning Workspace

```
<target-dir>/planning-workspace/
+-- config.md
+-- target-summary.md
+-- agents/
|   +-- agent-1-<name>/brief.md
|   +-- agent-2-<name>/brief.md
+-- synthesis/
```

## 5. Round 1 -- Independent Research

Launch ALL agents in parallel in a SINGLE message using the `research-agent` agent definition.

## 6. Round 2+ -- Cross-Pollinate

Launch ALL agents again in parallel. Each reads all others' prior round outputs before writing.

Stop early if agents' Top 3 priorities are aligned and disagreements are resolved.

## 7. Synthesize

Launch ONE synthesis agent using `research-synthesizer`.

## 8. Present Results

Present the Executive Summary, highlight tradeoffs requiring user input, and offer to dive deeper or begin implementation.

## Important Rules

- **All agents in a round launch in ONE message.**
- **Agents must read actual code**, not just the summary.
- **The synthesis agent is a judge**, not a summarizer.
- **The workspace is inspectable** -- don't delete intermediate files.
- **The proposal step is mandatory** -- get user confirmation on angles.
