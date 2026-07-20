---
name: review-pr-comments
description: Review PR comments, apply or reject each one with evidence, and post replies directly to GitHub
argument-hint: [pr-number-or-url]
---

# PR Comments Review

Review PR comments from reviewers, make deliberate decisions about each, apply code changes where appropriate, and reply directly on GitHub.

## 1. Determine Which PR

If `$ARGUMENTS` contains a PR number or URL, use it. Otherwise, ask using `AskUserQuestion`:

> "Which PR's comments do you want to review?"

Options:
1. **Current branch's PR** - Find the PR for the current branch.
2. **A specific PR number** - The user will type the number.

Store as `PR_NUMBER`.

## 2. Fetch PR Context

```bash
gh pr view $PR_NUMBER --json title,body,url,state,headRefName,baseRefName
gh pr diff $PR_NUMBER
gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/pulls/$PR_NUMBER/comments --paginate
gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/pulls/$PR_NUMBER/reviews --paginate
```

If there are no comments, inform the user and stop.

Present a summary: PR title/state, number of comments, which files have comments.

## 3. Analyze Each Comment

### 3a. Understand the Context

1. What is the current behavior in the code?
2. What does the comment suggest changing?
3. Read the full file (not just the diff).

### 3b. Validate Against the Codebase

- **Pattern check**: Run the **pattern-scout** agent if the comment suggests a new approach.
- **Type check**: Verify against actual type definitions and analysis_options.yaml rules.
- **Test check**: Check what the tests expect.

### 3c. Decide

For each comment:
1. **Apply** - Correct, improves the code, within scope.
2. **Reject** - Incorrect, unnecessary, or out of scope. Provide evidence.
3. **Ambiguous** - Has merit but unclear. State interpretation, then apply.

Record 1-3 evidence bullets from the codebase.

## 4. Apply Code Changes

For each "Apply" or "Ambiguous -> Applied" decision:

1. Make the **minimal change** needed.
2. Preserve existing style and architecture.
3. Run verification:
   ```bash
   cd menu_management && flutter analyze
   cd menu_management && flutter test test/
   ```
4. If Freezed models changed: `cd menu_management && dart run build_runner build --delete-conflicting-outputs`
5. Commit: `fix: address PR review - <short description>`
6. Push: `git push origin HEAD`

## 5. Post Replies to GitHub

```bash
gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)/pulls/{pr_number}/comments/{comment_id}/replies -f body="<reply>"
```

### Reply Format

- **Applied**: `**Applied** in <short-sha> - <one sentence>.`
- **Rejected**: `**Reject** - <1-3 sentences with evidence>.`
- **Ambiguous**: `**Ambiguous -> Applied** in <short-sha> - Interpreted as: <interpretation>. <what changed>.`

### Important Rules

- **Do NOT resolve/unresolve review threads.** Leave that to human reviewers.
- Read the full thread before deciding -- the author may have clarified.

## 6. Critical Standards

- **Be Skeptical**: Do not accept comments without evidence.
- **Minimal Changes**: No refactoring unrelated to the comment.
- **Preserve Intent**: Maintain existing code style and architecture.
- **Evidence Over Authority**: Base decisions on code evidence.
- **Scope Discipline**: Reject out-of-scope suggestions with a note to open a separate issue.

## 7. Report Summary

```
## PR Comments Review Summary

**PR:** #<number> - <title>
**Comments reviewed:** N

### Applied (N)
- Comment by @user on `file:line` - <what was changed>

### Rejected (N)
- Comment by @user on `file:line` - <why rejected>

### Ambiguous -> Applied (N)
- Comment by @user on `file:line` - <interpretation>. <what was changed>

### Verification
- Analysis: pass/fail
- Tests: pass/fail
```
