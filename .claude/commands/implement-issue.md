---
name: implement-issue
description: Implement a GitHub issue interactively - asks about branch, PR target, and phases/steps before starting work
argument-hint: [issue-number]
---

# Interactive Issue Implementation

Implement a GitHub issue by interactively gathering configuration through questions, then processing steps sequentially with automated PR creation and review cycles.

## 1. Determine the Issue

- If `$ARGUMENTS` contains an issue number, use it as `ISSUE`.
- If `$ARGUMENTS` is empty, ask the user using `AskUserQuestion`:
  > "Which GitHub issue do you want to implement?"

## 2. Fetch and Parse the Issue

```bash
gh issue view $ISSUE --json title,body,number
```

Display the issue title to the user so they can confirm context.

Parse the issue body to extract:
- **Sub-issues**: collect all `#<number>` references if any.
- **Steps/phases**: any numbered or grouped structure.

## 3. Ask: Working Branch

Use `AskUserQuestion` to ask:

> "Do you want to implement the changes in a new branch or use the current one?"

Options:
1. **Create or switch to a different branch** - Specify a branch name.
2. **Current branch (`<current-branch-name>`)** - Work on the branch you're already on.

If the user picks option 1:
- Ask for the branch name.
- Check if the branch exists locally or remotely:
  - If it exists: `git checkout <branch> && git pull origin <branch>`
  - If it does not exist: create it from the current branch:
    ```bash
    git checkout -b <branch> && git push -u origin <branch>
    ```

Store the chosen branch as `WORK_BRANCH`.

## 4. Ask: PR Target Branch

Use `AskUserQuestion` to ask:

> "Which branch should PRs target?"

Options:
1. **main** - PRs will target the main branch directly.
2. **Current branch (`<WORK_BRANCH>`)** - PRs will target the working branch.
3. **Custom branch** - Specify a different target branch.

Store the chosen branch as `PR_TARGET_BRANCH`.

## 5. Analyze Steps

### 5a. If the issue has explicit phases or sub-issues

Present the detected structure to the user and ask using `AskUserQuestion`:

> "This issue has <N> steps. Which one do you want to implement?"

Options (up to 4):
1. **Step 1: <summary>**
2. **Step 2: <summary>**
3. **All steps sequentially** - Implement all steps one after another.

Store the chosen step as `TARGET_STEP`.

### 5b. If the issue has NO explicit steps or sub-issues

Analyze the issue body to determine if it makes sense to split it into multiple implementation steps. Consider:
- Number of distinct features or changes described
- Whether changes touch different parts of the codebase
- Whether there are natural dependency boundaries

**If splitting makes sense**, present the proposed steps to the user using `AskUserQuestion`:

> "This issue doesn't have explicit steps, but I'd suggest splitting it into <N> steps:"
>
> 1. <Step 1 summary>
> 2. <Step 2 summary>
>
> "Should I proceed with these steps?"

Options:
1. **Yes, implement step by step** - Proceed with the proposed steps.
2. **No, implement it all at once** - Implement everything in a single pass.

If the user chooses step by step, ask which step to implement (same as 5a).

**If splitting does NOT make sense** (simple, focused issue), proceed directly to implementation as a single unit.

## 6. Validate Pre-conditions

Before starting any work:

1. Confirm the working branch is up to date:
   ```bash
   git checkout $WORK_BRANCH && git pull origin $WORK_BRANCH
   ```
2. Run `flutter analyze` to ensure a clean starting state:
   ```bash
   cd menu_management && flutter analyze
   ```

## 7. Execute Implementation

### 7a. Multi-step mode

For **each step**, one at a time:

1. **Create a branch** from `$WORK_BRANCH`:
   ```bash
   git checkout -b <issue-number>-<short-slug> $WORK_BRANCH
   git push -u origin <issue-number>-<short-slug>
   ```

2. **Spawn an implementation agent** (using `Agent` tool with `isolation: "worktree"`) with this prompt:

   > You are implementing GitHub issue #<NUMBER> for the Menu Management Flutter app.
   >
   > ## Issue Details
   > <Paste the full issue title and body here>
   >
   > ## Step to implement
   > <Paste the specific step details>
   >
   > ## Instructions
   > 1. Read the project's `CLAUDE.md` for conventions and verification commands.
   > 2. Run the **pattern-scout** agent before writing any code to find existing patterns.
   > 3. **Diagnose first**: Search the codebase for relevant files. Identify the exact locations that need changing. Explain the reasoning before writing any code.
   > 4. **Plan if complex**: If the fix involves more than 2 files, create a checklist of all required changes before starting.
   > 5. Implement the changes following the patterns found and the requirements in the issue.
   > 6. If you modified any Freezed model, run: `cd menu_management && dart run build_runner build --delete-conflicting-outputs`
   > 7. Run verification: `cd menu_management && flutter analyze`
   > 8. Fix any lint or analysis errors before finishing.
   > 9. Create commits for your changes.
   > 10. Push your branch: `git push origin HEAD`
   >
   > ## Branch
   > Work on branch: `<issue-number>-<short-slug>`
   > Base branch: `$WORK_BRANCH`
   >
   > ## Scope
   > Only implement what is described in the step. Do not modify code outside the scope.

3. **Wait for the agent to complete.**

4. **Create a PR**:

```bash
gh pr create \
  --base $PR_TARGET_BRANCH \
  --head <issue-number>-<short-slug> \
  --title "<short title>" \
  --body "$(cat <<'PREOF'
## Summary

Closes #<ISSUE_NUMBER>

<1-3 bullet points summarizing what was done>

## Test plan

- [ ] `flutter analyze` passes
- [ ] App runs without errors
- [ ] Manual verification of the feature

🤖 Generated with [Claude Code](https://claude.com/claude-code)

PREOF
)"
```

5. **Run the automated review cycle** (section 8) before moving to the next step.

### 7b. Single-issue mode

1. **Work directly on `$WORK_BRANCH`** (no sub-branch needed).
2. **Spawn an implementation agent** with the same prompt template as 7a, but referencing the full issue.
3. **Create a PR** targeting `$PR_TARGET_BRANCH`.
4. **Run the automated review cycle** (section 8).

## 8. Automated Review Cycle

For each PR, run a review cycle using a **local file** to keep the feedback loop fast.

The review file path is: `.reviews/<issue-number>-review.md`

### 8a. Spawn a review agent

Spawn a **new agent without prior context** to review the PR:

> You are reviewing a pull request for the Menu Management Flutter app.
>
> ## PR Details
> - PR number: <PR_NUMBER>
> - Branch: <BRANCH_NAME>
>
> ## Instructions
> 1. Fetch the PR details: `gh pr view <PR_NUMBER> --json title,body,url,headRefName,baseRefName`
> 2. Fetch the full diff: `gh pr diff <PR_NUMBER>`
> 3. Read the project's `CLAUDE.md` for conventions.
> 4. Review the code changes for:
>    - Correctness: Does the code do what the issue asks?
>    - Patterns: Does it follow existing codebase patterns (Provider, Freezed, etc.)?
>    - Types: Are all types explicit? Does it match analysis_options.yaml rules?
>    - Scope: Are changes limited to what the issue requires? No over-engineering?
>    - Style: Double quotes, package imports, 150-char line width?
> 5. Write your review to `.reviews/<PR_NUMBER>-review.md`:
>    ```markdown
>    # Review: PR #<PR_NUMBER> -- <PR title>
>
>    ## Verdict: APPROVED | CHANGES_REQUESTED
>
>    ## Summary
>    <1-3 sentence assessment>
>
>    ## Issues
>    <!-- Leave empty if APPROVED -->
>
>    ### Issue 1: <short title>
>    - **File:** `<file-path>`
>    - **Line(s):** <line number or range>
>    - **Severity:** critical | high | medium | low
>    - **Description:** <what's wrong and why>
>    - **Suggestion:** <how to fix it>
>    ```
>    Create `.reviews/` if it doesn't exist: `mkdir -p .reviews`

### 8b. If changes are requested, iterate

Read the review file. If verdict is `CHANGES_REQUESTED`:

1. Spawn an implementation agent on the same branch to address every issue.
2. Delete the old review file.
3. Spawn a **new review agent** (fresh context) to review again.
4. **Repeat** until `APPROVED` (max 3 iterations).

### 8c. Clean up

Once approved:

```bash
rm -f .reviews/<PR_NUMBER>-review.md
rmdir .reviews 2>/dev/null || true
```

Notify the user that the review passed.

**Do not merge the PR.** Wait for the user to review, approve, and merge manually.

## 9. Completion

After all steps are done, report:

> All steps complete. PRs are ready for human review.

If there are remaining steps, report:

> Step <N> complete. Remaining steps: <list>
> Run `/implement-issue <ISSUE>` to continue.

## Important Rules

- **Never push to `main` directly.** All work goes through branches and PRs.
- **Never merge PRs automatically.** Always wait for human approval.
- **Scope discipline.** Each agent works only on its assigned step. No cross-step changes.
- **Verification is mandatory.** Every agent must run `flutter analyze` before pushing.
- **Fresh reviewers.** Review agents must have no context from the implementation.
- **Max 3 review iterations.** If after 3 rounds the review still has issues, notify the user and move on.
- **Interactive first.** Always use `AskUserQuestion` to gather configuration. Never assume defaults silently.
