---
name: review-pr
description: Perform a comprehensive code review on a PR or branch, posting comments directly to GitHub
argument-hint: [pr-number-or-branch]
---

# PR Code Review

Perform a thorough code review on a pull request or branch, then post the review directly to GitHub.

## 1. Determine What to Review

If `$ARGUMENTS` contains a PR number, branch name, or URL, use it. Otherwise, ask using `AskUserQuestion`:

> "Which PR or branch do you want to review?"

Options:
1. **Current branch** - Review the current branch against its base.
2. **A specific PR number** - The user will type the PR number.
3. **A specific branch** - The user will type the branch name.

Then ask using `AskUserQuestion`:

> "Which base branch should I compare against?"

Options:
1. **main (Recommended)** - Compare against the main branch.
2. **The PR's base branch** - Use whatever the PR targets (only if a PR number was given).
3. **Custom branch** - The user will specify.

Store as `TARGET` (the PR number or branch to review) and `BASE_BRANCH`.

## 2. Establish the Diff Baseline

Gather full context about the changes:

```bash
# If reviewing a PR
gh pr view $TARGET --json title,body,author,labels,headRefName,baseRefName,url

# List commits
git log $BASE_BRANCH...$TARGET --oneline

# Full diff
git diff $BASE_BRANCH...$TARGET

# Changed files with stats
git diff --name-only --diff-filter=ACMRD $BASE_BRANCH...$TARGET
git diff --stat $BASE_BRANCH...$TARGET
```

Identify:
- Which feature domain(s) are touched (ingredients, recipes, menu, shopping, theme, flutter_essentials)
- The commit messages and any PR description for stated intent
- Total scope (additions/deletions, number of files)

## 3. Issue Alignment

Check whether the PR references one or more issues:

```bash
gh pr view $TARGET --json closingIssuesReferences,body
```

If associated issues exist, fetch each one:

```bash
gh issue view <issue_number> --json title,body,comments
```

Assess:
- Does the PR address what each issue asked for?
- Are there deliverables described in the issues that are **missing** from the PR?
- Does the PR introduce scope beyond what the issues requested?

If no issues are linked, note this in the review but do not treat it as a blocker.

**Pause here.** Report your findings on issue alignment and confirm you should proceed before continuing.

## 4. Read the Changed Files

For every changed file in the diff, read its **current state** (not just the diff) so you understand the full context. Pay particular attention to:

- New or modified Freezed models
- New or modified providers (state management changes)
- New or modified widgets (UI changes)
- New or modified business logic (menu generation, recipe validation)
- Changes to `flutter_essentials/` (shared utilities)
- Config changes: `pubspec.yaml`, `analysis_options.yaml`

## 5. Run the Pattern Scout

If the PR introduces a new feature or pattern (new widget, new provider method, new model, new dialog), delegate to the **pattern-scout** agent to check whether the PR follows established conventions:

> Analyze how [feature type] is implemented elsewhere in the codebase. Does this PR follow the established conventions?

Note any deviations from established patterns.

## 6. Verification

Run the project verification commands:

```bash
cd menu_management && flutter analyze
```

If the PR modified any Freezed models, also run:

```bash
cd menu_management && dart run build_runner build --delete-conflicting-outputs
```

If analysis fails, note the errors as findings.

## 7. Structured Code Review

Go through each checklist area below. For every issue found, record it with:
- **Severity**: `critical` | `major` | `minor` | `nit`
- **File and line reference**
- **Description of the issue**
- **Rationale** (why this matters)
- **Suggested fix** (concrete, not vague)

### 7a. Architecture & Patterns

- [ ] Does the code follow the Provider-based architecture (Widgets -> Providers -> Freezed Models)?
- [ ] Are new providers structured as singletons with static mutation methods?
- [ ] Are new models using Freezed with proper `copyWith`, equality, and JSON serialization?
- [ ] Are new widgets placed in the correct feature domain directory?
- [ ] Does the code use `listenableOf()` where appropriate for fine-grained rebuilds?
- [ ] Are new utilities placed in `flutter_essentials/` and exported from `library.dart`?

### 7b. Type Annotations & Lint Rules

- [ ] All function parameters have explicit type annotations
- [ ] All return types are annotated
- [ ] Double quotes used throughout (not single quotes)
- [ ] Package imports only (no relative lib imports)
- [ ] Line width within 150 characters
- [ ] `@override` annotations present

### 7c. Freezed Model Correctness

- [ ] Generated files (`*.freezed.dart`, `*.g.dart`) are up to date with the model definition
- [ ] Business logic methods on models are pure (no side effects)
- [ ] JSON serialization roundtrips correctly (fromJson/toJson)
- [ ] New fields have sensible defaults or are required

### 7d. State Management

- [ ] Provider mutations call `notifyListeners()` after state changes
- [ ] No direct state mutation of Freezed objects (should use `copyWith`)
- [ ] Widget rebuilds are appropriately scoped (not rebuilding entire trees)

### 7e. Code Quality & Style

- [ ] No dead code, commented-out blocks, or debug print statements
- [ ] No unnecessary duplication -- similar logic already existing should be reused
- [ ] Naming is consistent (snake_case files, PascalCase classes, camelCase variables)
- [ ] File and module organization matches the existing structure
- [ ] No over-engineering: unnecessary abstractions, premature generalization

### 7f. ADR Compliance

- [ ] Check if the changes touch areas covered by existing ADRs (state management, persistence, menu generation, multi-step recipes, cook mode, flutter_essentials)
- [ ] If so, do the changes comply with the recorded decisions?
- [ ] If the PR introduces a new architectural pattern, flag that an ADR should be created

## 8. Compose and Publish Review Comments

Draft comments grouped by theme. Each comment must be:
- **Actionable:** concrete suggestion, not just a description
- **Rationale included:** explain *why* this matters
- **Severity labeled:** `critical`, `major`, `minor`, or `nit`
- **No noise:** exclude findings that are product/UX decisions rather than code concerns

### Attribution

Every comment must be prefixed with:

```
> 🤖 **Claude Code Review** | Area: [Architecture / Types / State Management / Code Quality / Issue Alignment]
```

### Publishing flow

**Pause before publishing each comment.** Show the draft to the reviewer, incorporate their feedback, and only publish with explicit approval.

```bash
gh pr comment <PR_NUMBER> --body "..."
```

### Final verdict

**If the PR looks good:**
```bash
gh pr review <PR_NUMBER> --approve --body "🤖 **Claude Code Review** -- LGTM. <brief reason>"
```

**If there are critical or major issues:**
```bash
gh pr review <PR_NUMBER> --request-changes --body "🤖 **Claude Code Review** -- Changes requested. See individual comments for details."
```

**If there are only minor issues:**
```bash
gh pr review <PR_NUMBER> --comment --body "🤖 **Claude Code Review** -- Looks good overall. A few minor suggestions posted as comments."
```

## 9. Present Summary to the User

Present the review locally:

---

### Summary

Brief 2-4 sentence overview of what the PR does, whether the approach is sound, and your overall recommendation.

**Recommendation:** `Approve` | `Approve with minor fixes` | `Request changes`

---

### Issue Alignment

Summary of whether the PR matches its linked issues. Flag any missing deliverables or unexpected scope.

---

### Critical Issues

> Must be resolved before merge.

(List items with file:line references, rationale, and suggested fixes, or "None".)

---

### Major Issues

> Should be resolved before merge; may block depending on impact.

(List items, or "None".)

---

### Minor Issues & Nits

> Low-risk improvements, style consistency, optional suggestions.

(List items, or "None".)

---

### Positive Observations

Call out things done well. This reinforces good patterns.

---

### Checklist Summary

| Area | Status |
|------|--------|
| Issue Alignment | pass / warning / fail / N/A |
| Architecture & Patterns | pass / warning / fail |
| Type Annotations & Lint | pass / warning / fail |
| Freezed Model Correctness | pass / warning / fail / N/A |
| State Management | pass / warning / fail |
| ADR Compliance | pass / warning / fail / N/A |
| Code Quality | pass / warning / fail |
