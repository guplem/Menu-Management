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

Store findings as `CODE_CONTEXT`.

## 5. Search for Duplicates and Related Issues

### 5a. Search open issues

```bash
gh issue list --state open --limit 100 --json number,title,labels,body
```

### 5b. Search recently closed issues

```bash
gh issue list --state closed --limit 50 --json number,title,labels,body
```

### 5c. Analyze matches

Compare the new issue's intent against fetched issues. Look for:
- **Exact duplicates**: Same problem described differently.
- **Related issues**: Issues that touch the same area or feature.
- **Closed duplicates**: Issues that were already resolved.

### 5d. Report findings

**If likely duplicates are found:**

Ask using `AskUserQuestion`:
> "I found an existing issue that looks like it covers the same problem:
> - #<NUMBER> - <TITLE> (<STATE>)
>
> What would you like to do?"

Options:
1. **It's a duplicate, stop** - Do not create the issue.
2. **It's related but different, link it** - Create the new issue and reference the existing one.
3. **Ignore, create anyway** - Proceed without linking.

**If related (but not duplicate) issues are found:**

Present them:
> "I found some related issues: #X, #Y. I'll reference them in the new issue."

Store related issue numbers as `RELATED_ISSUES`.

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

### 6b. Priority label (infer one)

- **P: High** - App crashes, data loss, core feature broken
- **P: Medium** - Degraded functionality, workaround exists
- **P: Low** - Cosmetic, minor inconvenience, nice-to-have

### 6c. Store labels for combined review

Do not ask the user to confirm labels separately. Store the proposed labels as `PROPOSED_LABELS` and present them together with the draft in Step 8.

## 7. Draft the Issue

Compose the issue body based on `ISSUE_TYPE`. Use the templates below, but **aggressively eliminate redundancy**.

### Bug template

```markdown
## Context

<What is broken, who is affected, and why it matters. Do NOT state root causes as fact -- use hedging language like "most likely caused by" or "may be related to".>

## Steps to Reproduce

1. <Step 1>
2. <Step 2>
3. <Observe...>

## Expected Behavior

<What should happen instead. Only include if not obvious from Context.>

## Proposed Solution

<High-level approach based on code investigation. Reference specific files/functions.>

## Acceptance Criteria

- [ ] <Issue-specific criterion that defines "done">
- [ ] <Edge case or regression guard, if applicable>

## Related Issues

<Links to related issues. Omit this section entirely if there are none.>
```

### Feature template

```markdown
## Context

<Why this feature is needed -- what user need does it serve.>

## Proposed Solution

<What the feature should do AND how to implement it. Reference existing patterns or code paths.>

## Acceptance Criteria

- [ ] <Issue-specific criterion that defines "done">
- [ ] <Additional criterion if needed>

## Related Issues

<Links to related issues. Omit this section entirely if there are none.>
```

### Improvement template

```markdown
## Context

<What exists today, its limitations, and why improvement is needed.>

## Proposed Solution

<How it should work after the improvement AND the technical approach. Reference specific files/functions.>

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
6. **Proposed Solution must add implementation detail.** Name specific files, functions, patterns, or ADRs.
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
- **Auto-infer, then confirm.** For type, labels, and priority: propose values and let the user adjust.
- **Code verification is mandatory for bugs.** Always check if the bug exists in the current code before creating.
- **Duplicate check is mandatory.** Always search open and closed issues before creating.
- **Respect the user's time.** Only ask questions when you genuinely can't infer the answer. Batch confirmations where possible.
- **Keep acceptance criteria testable.** Each criterion should be something `/implement-issue` can verify.
- **No redundancy.** Every sentence must earn its place.
