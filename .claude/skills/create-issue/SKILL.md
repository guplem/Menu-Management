---
name: create-issue
description: Create a well-structured GitHub issue with duplicate detection, code verification, and auto-labeling
argument-hint: [brief description]
---

# Interactive Issue Creation

Create a GitHub issue with a standardized structure, duplicate detection, code verification, and auto-labeling.

## 1. Gather Initial Context

### 1a. Determine the starting input

- If `$ARGUMENTS` contains a text description, use it as the initial context.
- If `$ARGUMENTS` is empty, ask using `AskUserQuestion`:
  > "Describe the issue you want to create. A sentence or two is enough -- I'll help structure it."

### 1b. Ask for additional context

Ask using `AskUserQuestion`:

> "Do you have any links with additional context (e.g., error logs, screenshots, related discussions)?"

Options:
1. **Yes, here's a link** - The user will paste a URL.
2. **No, let's continue with what I described** - Proceed without external context.

## 2. Deep Understanding -- Clarify Until Crystal Clear

**This step is mandatory and must not be skipped.** Before moving forward, you must be fully confident that you understand exactly what the user wants.

### 2a. Summarize your understanding

Write a short, concrete summary of:
- **What** the user is describing (the problem, feature, or improvement)
- **Why** it matters (impact, who is affected, what breaks or is missing)
- **Where** in the system it applies (which feature domains, widgets, providers, or models)

### 2b. Identify gaps and ambiguities

Critically evaluate your summary. Ask yourself:
- Could this description mean two different things?
- Is the scope clear -- do I know what's in and what's out?
- For bugs: Do I know the exact reproduction path, or am I guessing?
- For features/improvements: Do I know the desired behavior precisely, or is it vague?

### 2c. Ask clarifying questions (repeat until clear)

If **any** gap or ambiguity exists, ask clarifying questions. **Ask one question at a time** using `AskUserQuestion` with options when applicable. Do not proceed until every question is answered. Common clarifications:

- "When you say X, do you mean A or B?"
- "What is the expected behavior? What should happen instead?"
- "Is this limited to [feature domain], or does it affect other areas too?"
- "Can you give me a concrete example or scenario?"

**Rules for this step:**
- **One question at a time.** Never dump multiple questions in a single message.
- **Never assume.** If something could be interpreted two ways, ask.
- **Iterate.** If the user's answer raises new questions, ask those too.
- **Don't interrogate unnecessarily.** If the description is genuinely clear, a brief confirmation is enough.

Once you are confident you understand the issue completely, proceed to Step 3.

## 3. Determine Issue Type

Analyze the combined context and infer the issue type:

- **Bug** - Something is broken or behaving incorrectly
- **Feature** - A new capability that doesn't exist yet
- **Improvement** - Enhancement to an existing feature
- **Task** - Refactors, chores, and other specific pieces of work

Only ask using `AskUserQuestion` if the type is truly ambiguous. Otherwise, infer silently and confirm later in the combined review (Step 8).

Store the selected type as `ISSUE_TYPE`.

## 4. Investigate the Codebase

Before structuring the issue, investigate the relevant code:

1. **Identify affected areas**: Determine which feature domains (ingredients, recipes, menu, shopping, theme, flutter_essentials) are involved.
2. **Search the codebase**: Find the relevant code paths, providers, models, and widgets.
3. **For bugs**: Verify the bug actually exists in the current code. If the code looks correct:
   - Report to the user: "I checked the code and this appears to already be handled in `<file>:<line>`. Are you sure you want to create this issue?"
   - If the user confirms, proceed. If not, stop.
4. **For features/improvements**: Identify the existing code that would need to change, and any patterns already in place. Run the **pattern-scout** agent if a new pattern is being introduced.
5. **Check relevant ADRs**: Run the **adr-checker** agent in consult mode to find ADRs that affect the planned work.

Store findings as `CODE_CONTEXT`. This context feeds the issue's Context section and the label detection; it is **not** a proposed solution (see Step 7).

## 5. Search for Duplicates and Related Issues

Do **not** fetch "the newest N issues": `gh issue list --limit N` returns only the most recently created, so an older duplicate is never seen. Search by **relevance across the whole repo**, both states. Scope every `gh search issues` to this repo with `--repo guplem/Menu-Management` (without it, `gh search` queries all of GitHub).

1. **Derive 2-4 keyword sets** from the issue intent (Step 3) and `CODE_CONTEXT`, each a few words, varied so together they cover how a duplicate might be worded: the feature or component name; the symptom or user-facing effect; the specific entity or code path. Each set must include the exact noun a person would put in the **title** -- the title is the strongest duplicate signal.
2. **Search each set, relevance-ranked** (put the keywords BEFORE any qualifier, or `gh search` returns an empty list):
   ```bash
   gh search issues --repo guplem/Menu-Management "<keywords> in:title" --limit 20 --json number,title,state,stateReason,url   # title-scoped: strongest signal
   gh search issues --repo guplem/Menu-Management "<keywords>" --limit 30 --json number,title,state,stateReason,url            # title + body: differently worded duplicates
   ```
3. **Recency backup, once**: `gh issue list --state all --limit 40 --json number,title,state,stateReason,labels`. It catches duplicates that use none of your keywords and brand-new issues the search index has not picked up yet (`gh search` is eventually consistent).
4. **Compare intent, not wording.** `stateReason` separates `COMPLETED` from `NOT_PLANNED`; treat any `NOT_PLANNED` match as a **reopen candidate**, not a reason to create a duplicate (backlog issues are often closed as not-planned to reopen later).
5. **If a likely duplicate exists**, ask via `AskUserQuestion`: stop (duplicate) / link it (related but different) / create anyway. **Prefer reopening a matching not-planned issue over creating a duplicate.**
6. Store related issue numbers as `RELATED_ISSUES`.

## 6. Auto-Detect Labels

Based on the issue description, code investigation, and type, select labels.

### 6a. Feature domain labels (select all that apply)

Map affected code paths to labels:

| Code path pattern | Label |
|---|---|
| `ingredients/` | `ingredients` |
| `recipes/` | `recipes` |
| `menu/`, `menu_generator` | `menu` |
| `shopping/` | `shopping` |
| `flutter_essentials/` | `utilities` |
| `theme/` | `theme` |
| `persistency` | `persistence` |

### 6b. Never assign priority labels

Priority is a human decision made when triaging, not something the agent infers. Never assign a priority label (`P: High` / `P: Medium` / `P: Low`).

### 6c. Store labels for combined review

Do not ask the user to confirm labels separately. Store the proposed labels as `PROPOSED_LABELS` and present them together with the draft in Step 8.

## 7. Draft the Issue

Compose the issue body based on `ISSUE_TYPE`, then apply the TL;DR rule, the Proposed Solution rule, and the anti-redundancy rules below. Use the templates, but **aggressively eliminate redundancy**.

### TL;DR rule (mandatory, all templates)

Every issue body must start with a **TL;DR** line before any section header:

```markdown
**TL;DR:** <one sentence summarizing what this issue achieves or fixes>
```

The TL;DR is one sentence (two only if genuinely necessary) that tells a reader what the issue is about without reading anything else. The title alone is rarely enough. It describes the **outcome**, not the process. A TL;DR names what this issue makes true (the "after") plus what it replaces (the "before"). For brand-new capabilities, the "before" is empty: state the new capability and why it matters.

Examples:

- Good (change): "Currently the recipe editor silently drops an ingredient with no quantity; this issue makes the editor block save until every ingredient has a quantity."
- Good (new capability): "Add a panel that surfaces per-week ingredient waste, so menus can be tuned without exporting data."
- Bad (after only): "Validate ingredient quantities before save." The reader cannot tell what is broken today.
- Bad (before only): "Deleted recipes still appear in the menu." States the gap but not what this issue makes true.

### Proposed Solution rule (mandatory)

**Never include a "Proposed Solution" section unless the user proposed a solution during issue creation.** A solution counts as user-proposed when it came from the user directly, or from source material the user brought (a linked discussion, a decision they quoted). Your own code investigation (Step 4) is **not** a user-proposed solution.

- If the user proposed a solution, include the section and write it from what they said. You may add file/function references from `CODE_CONTEXT` to make their idea concrete, but the approach must be theirs.
- If the user did **not** propose a solution, **omit the section entirely.** The investigation still feeds Context and verifies bugs; it does not produce a solution the user never asked for.

### Bug template

```markdown
**TL;DR:** <one sentence with the after and the before. "Currently X; this issue makes Y." or "Y instead of X.">

## Context

<What is broken, who is affected, and why it matters. Combine the problem description and current behavior into one cohesive narrative. Do NOT state root causes as fact -- use hedging language like "most likely caused by" or "may be related to".>

## Steps to Reproduce

1. <Step 1>
2. <Step 2>
3. <Observe...>

## Expected Behavior

<What should happen instead. Only include if not obvious from Context.>

## Proposed Solution

<ONLY if the user proposed one; otherwise omit this entire section.>

## Acceptance Criteria

- [ ] <Issue-specific criterion that defines "done">
- [ ] <Edge case or regression guard, if applicable>

## Related Issues

<Links to related issues. Omit this section entirely if there are none.>
```

### Feature template

```markdown
**TL;DR:** <one sentence: what new capability this adds and why it matters>

## Context

<Why this feature is needed AND what it should do at a high level.>

## Proposed Solution

<ONLY if the user proposed one; otherwise omit this entire section.>

## Acceptance Criteria

- [ ] <Issue-specific criterion that defines "done">
- [ ] <Additional criterion if needed>

## Related Issues

<Links to related issues. Omit this section entirely if there are none.>
```

### Improvement template

```markdown
**TL;DR:** <one sentence with the after and the before>

## Context

<What exists today, its limitations, and why improvement is needed.>

## Proposed Solution

<ONLY if the user proposed one; otherwise omit this entire section.>

## Acceptance Criteria

- [ ] <Issue-specific criterion that defines "done">
- [ ] <Additional criterion if needed>

## Related Issues

<Links to related issues. Omit this section entirely if there are none.>
```

### Anti-redundancy rules (mandatory)

Before finalizing the draft, re-read it and apply these rules:

1. **No section should restate another section.** Merge overlapping content.
2. **Context must not restate the title.**
3. **Acceptance Criteria must not restate Expected Behavior.** Each checkbox should tell the implementer something new.
4. **No generic AC items.** Do not include "lint passes", "no regressions", "tests pass". Every AC item must be specific to THIS issue.
5. **Omit empty or boilerplate sections.**
6. **A kept Proposed Solution must add implementation detail** (specific files, functions, patterns, or ADRs), never a restatement of Expected Behavior.
7. **Redundancy self-check.** After writing, read each section and ask: "If I deleted this, would the reader lose any information?" If no, delete it.

### 7b. Generate Title Options and Get User Choice

Generate **2-3 title candidates**. Each title must:

- Be under 80 characters
- Be concise and specific -- describe the outcome, not the process
- NOT include a conventional prefix (`fix:`, `feat:`, etc.)

Vary the titles by focus:
1. **User-facing**: Describes the impact from a user's perspective
2. **Technical**: Describes the component or root cause
3. **Action-oriented** (optional 3rd): Describes what needs to happen

Present options using `AskUserQuestion`. The user picks one or provides a custom title.

Store the selected title as `SELECTED_TITLE`.

## 8. Draft Review with User

Present the full draft for review:

1. **Issue type**: `ISSUE_TYPE`
2. **Selected title**: `SELECTED_TITLE`
3. **Labels**: `PROPOSED_LABELS`
4. **Related issues**: `RELATED_ISSUES`
5. **Full draft body**

Then ask using `AskUserQuestion`:

> "Here's the full draft. Would you like any changes?"

Options:
1. **Looks good, create it**
2. **Make changes first** - The user will describe what to adjust.

If changes requested, apply them and re-present.

## 9. Create the Issue

Always include the `waiting-for-human-check` label. If it doesn't exist in the repo, create it first:
```bash
gh label create "waiting-for-human-check" --description "No human has verified this yet -- direct AI output" --color "D93F0B" 2>/dev/null || true
```

```bash
gh issue create \
  --title "$SELECTED_TITLE" \
  --label "<label1>,<label2>,waiting-for-human-check" \
  --body "$(cat <<'EOF'
<full issue body>
EOF
)"
```

### 9b. Return the result

Present to the user:
- The issue URL
- The selected title
- The issue type
- The assigned labels
- Any linked issues

## Important Rules

- **Never create without confirmation.** Always show the draft and get user approval before creating.
- **Clarify before structuring.** Step 2 (Deep Understanding) is mandatory. Never skip it.
- **Auto-infer, then confirm.** Propose type and labels; let the user adjust in one combined review.
- **Code verification is mandatory for bugs.** Always check if the bug exists in the current code before creating.
- **Duplicate check is mandatory.** Always search open and closed issues before creating.
- **Respect the user's time.** Only ask questions when you genuinely can't infer the answer. Batch confirmations where possible.
- **Keep acceptance criteria testable.** Each criterion should be something `/implement-issue` can verify.
- **No redundancy.** Every sentence must earn its place.
