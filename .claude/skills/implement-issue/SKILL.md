---
name: implement-issue
description: Implement a GitHub issue step by step - ask about the branch and the PR target first (batched in one question), then run the work and the review cycle with the review-pr skill. Also accepts a plain problem description, which it files as an issue autonomously first. Use whenever the user asks to implement, work on, or execute a GitHub issue.
argument-hint: [issue-number | problem description]
---

# Interactive Issue Implementation

Implement a GitHub issue by interactively gathering configuration through questions, then processing steps sequentially with automated PR creation and review cycles.

## 1. Determine or Create the Issue

Read `$ARGUMENTS`:

- **An issue number** (digits, with or without a leading `#`): use it as `ISSUE`.
- **A problem description** (any other non-empty text): file it as an issue **autonomously** with the `create-issue` skill, then use the new number as `ISSUE`. Invoke it with the Skill tool: `skill: "create-issue", args: "<the description> --autonomous"`. Autonomous mode asks the user nothing: it infers the type, picks the title, drafts the body, and creates the issue on its own (see the `create-issue` skill's autonomous mode). Do not stop to confirm; the review cycle later is the safety net.
- **Empty**: ask the user using `AskUserQuestion`: "Which GitHub issue do you want to implement?"

## 2. Fetch, Parse, and Take Ownership

```bash
gh issue view $ISSUE --json title,body,number
```

Display the issue title to the user so they can confirm context.

Parse the issue body to extract:
- **Sub-issues**: collect all `#<number>` references if any.
- **Steps/phases**: any numbered or grouped structure.

**Self-assign the issue**, because you are taking ownership of the work:

```bash
gh issue edit $ISSUE --add-assignee @me
```

## 3. Ask: Branches (One Batched Question)

Ask both branch decisions in a **single `AskUserQuestion` call** (two questions in one batch), so the user answers them almost instantly from pre-filled options:

- **Working branch**: `New branch: <issue-number>-<short-slug>` (Recommended, slug derived from the issue title) / `Current branch`. The "Other" field takes a custom branch name. Store the choice as `WORK_BRANCH`.
- **PR target branch**: `main` (Recommended) / `Current branch`. The "Other" field takes a custom target. Store it as `PR_TARGET_BRANCH`.

Then set the working branch up **with the upstream set at once** (the `create-branch` skill). New branch: `git checkout -b <branch> && git push -u origin <branch>`. Existing branch: `git checkout <branch> && git pull origin <branch>`.

## 4. Analyze Steps

### 4a. If the issue has explicit phases or sub-issues

Present the detected structure to the user and ask using `AskUserQuestion`:

> "This issue has <N> steps. Which one do you want to implement?"

Options (up to 4):
1. **Step 1: <summary>**
2. **Step 2: <summary>**
3. **All steps sequentially** - Implement all steps one after another.

Store the chosen step as `TARGET_STEP`.

### 4b. If the issue has NO explicit steps or sub-issues

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

If the user chooses step by step, ask which step to implement (same as 4a).

**If splitting does NOT make sense** (simple, focused issue), proceed directly to implementation as a single unit.

## 5. Validate Pre-conditions

Before starting any work:

1. Confirm the working branch is up to date:
   ```bash
   git checkout $WORK_BRANCH && git pull origin $WORK_BRANCH
   ```
2. Spawn the **validate** agent to confirm the repo's checks pass before you start. Do not build on a broken baseline; report it to the user instead.

## 6. Execute Implementation

### 6a. Multi-step mode

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
   > 1. Read the project's `AGENTS.md` for conventions and verification commands.
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

4. **Create a PR** (always include `waiting-for-human-check` label and self-assign):

   Write the PR description in the repo's **Communicating with users** style (`AGENTS.md`): a reviewer skims it, so lead with what changed and why, in short plain sentences.

```bash
gh label create "waiting-for-human-check" --description "No human has verified this yet -- direct AI output" --color "D93F0B" 2>/dev/null || true
gh pr create \
  --base $PR_TARGET_BRANCH \
  --head <issue-number>-<short-slug> \
  --title "<short title>" \
  --assignee @me \
  --label "waiting-for-human-check" \
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

5. **Run the automated review cycle** (section 7) before moving to the next step.

### 6b. Single-issue mode

1. **Work directly on `$WORK_BRANCH`** (no sub-branch needed).
2. **Spawn an implementation agent** with the same prompt template as 6a, but referencing the full issue.
3. **Create a PR** targeting `$PR_TARGET_BRANCH`.
4. **Run the automated review cycle** (section 7).

## 7. Review Cycle (uses the review-pr skill)

Use the **review-pr** skill in `--no-verdict` mode. That mode runs unattended (it never asks the user anything), posts a COMMENT-only review to the PR, and writes a local findings file `.reviews/<PR_NUMBER>-review.md` with a clear verdict: `APPROVED` or `CHANGES_REQUESTED`. Invoke it with the Skill tool: `skill: "invoke", args: "review-pr <PR_NUMBER> --no-verdict"`.

1. Run `review-pr <PR_NUMBER> --no-verdict`, then read the verdict and every finding from `.reviews/<PR_NUMBER>-review.md`.

2. **Decide what to implement, using your judgement on every comment, not only the Required ones.** Always implement each `[Required]` finding. For each `[Suggestion]` and `[Nitpick]`, weigh whether it is worth doing now: is it a real bug or correctness gap? how much tech debt (future cost) does leaving it create? is it a small fix that makes later work easier? does it fit the issue's scope? Implement the ones your judgement says are worth it; leave the rest, each with a clear reason. Do not treat "not Required" as "not worth doing".

3. **Apply the chosen fixes** by spawning an implementation agent on the same branch, then run `review-pr <PR_NUMBER> --no-verdict` again (it re-reviews the whole current state and does not re-raise findings it already made). Repeat until there are no new findings you choose to act on, **at most 3 rounds**; then stop and report to the user.

4. **Reply on every inline comment thread the cycle posted**, so the PR owner sees each comment's status and the reason without reading commits. List the comment `id`s with `gh api repos/<owner>/<repo>/pulls/<PR_NUMBER>/comments --jq '.[] | {id, path, line}'`, then reply to each via the replies endpoint:
   ```bash
   gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/pulls/<PR_NUMBER>/comments/<COMMENT_ID>/replies -f body="<reply>"
   ```
   - **Implemented:** `**Applied** in <short-sha> - <one sentence on the change>.`
   - **Left unapplied on purpose:** `**Not applied** - <one-sentence reason>.`

5. **Resolve each thread after you reply to it**, so only threads still needing the human's attention stay open. GitHub resolves review threads through its GraphQL API (there is no plain `gh pr` command). First list the threads with their IDs, then resolve each:
   ```bash
   OWNER_REPO=$(gh repo view --json owner,name -q '.owner.login+" "+.name')
   gh api graphql -f query='query($o:String!,$n:String!,$pr:Int!){ repository(owner:$o,name:$n){ pullRequest(number:$pr){ reviewThreads(first:100){ nodes{ id isResolved comments(first:1){ nodes{ databaseId } } } } } } }' -F o=<owner> -F n=<repo> -F pr=<PR_NUMBER>
   gh api graphql -f query='mutation($id:ID!){ resolveReviewThread(input:{threadId:$id}){ thread{ isResolved } } }' -F id=<THREAD_ID>
   ```
   The thread nodes carry the first comment's `databaseId`, so you can match a thread to the comment you replied to.

6. **Reflect, then update the shared docs (do this every cycle).** For each finding you acted on, ask: "Is this a standard or best practice I should have followed from the start?" If yes, classify why the miss happened and fix the cause, so the same mistake does not recur:
   - **Guidance already existed** (in `AGENTS.md`, an ADR, or a skill): no doc change; you simply missed it.
   - **Guidance was missing:** add it to the right shared file via the `write-ai-instructions` skill (`AGENTS.md` for a rule, an ADR for a decision, a skill for a procedure).
   - **Guidance was weak or hard to find:** sharpen or relocate it.

   Persist every such lesson only in these **shared, version-controlled files** that all coworkers and their agents read; never in your personal memory or the user's global config, which teammates never see. Ride these doc changes along in the same PR and list them in the PR summary.

7. **Then finish:** delete the review file (and `.reviews/` if it is now empty) and tell the user.

**Do not merge the PR.** Wait for the user to review, approve, and merge manually.

## 8. Completion

After all steps are done, report:

> All steps complete. PRs are ready for human review.

If there are remaining steps, report:

> Step <N> complete. Remaining steps: <list>
> Run `/implement-issue <ISSUE>` to continue.

## Important Rules

- **Never push to `main` directly.** All work goes through branches and PRs.
- **Take ownership.** Self-assign the issue when you start it and self-assign every PR you open.
- **Never merge PRs automatically.** Always wait for human approval.
- **Scope discipline.** Each agent works only on its assigned step. No cross-step changes.
- **Verification is mandatory.** The implementation agent runs the repo's checks before pushing, and the orchestrator confirms a clean state with the **validate** agent.
- **Fresh reviewers.** The review agent has no context from the implementation (the `review-pr` skill already spawns fresh agents).
- **Bounded iteration.** At most 3 review rounds; then report to the user instead of looping.
- **Judgement on every comment.** Act on any comment worth acting on, not just the Required ones; reply and resolve each thread with the reason.
- **Learn in shared docs.** When feedback reveals a should-have-known standard, persist the lesson to `AGENTS.md`/ADR/skill, never to personal memory or global config.
- **Config is interactive, the issue write-up is autonomous.** Gather the branch and step config via `AskUserQuestion` (batched where possible); when given only a problem description, create the issue with `create-issue --autonomous` and ask nothing.
