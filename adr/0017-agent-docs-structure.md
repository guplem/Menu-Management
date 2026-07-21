# AGENTS.md map with Claude-Code-only skills, subagents, and enforcement layers

## Context

The repo already had a strong documentation layer: a single standalone `CLAUDE.md` holding all agent guidance, 15 ADRs, six subagents in `.claude/agents/`, and four commands in `.claude/commands/`. It also had a mandatory red-green TDD rule backed by hundreds of tests.

What it lacked was structure and enforcement:

- All agent guidance lived in one always-loaded `CLAUDE.md`, including procedures (how to create an issue, how to implement one) that only matter when doing that specific task.
- There was no continuous integration (CI): no automatic checks ran on a pull request, so a PR with failing tests or unformatted code could be merged.
- There was no branch protection or merge ruleset.
- The ADR guidance said to mark a superseded ADR and reference its successor, which grows a chain of dead files instead of keeping one live decision.

This repo is developed with Claude Code only, so no multi-tool synchronization machinery is needed.

## Decision

Adopt a shared personal standard for agent-facing repositories.

- **`AGENTS.md` is the always-loaded map** at the repo root: architecture facts, conventions, gotchas, and the ADR index. `CLAUDE.md` is a one-line `@AGENTS.md` shim so Claude Code loads it; tools that read `AGENTS.md` natively need no extra file. The `adr/` folder follows the same pair: `adr/AGENTS.md` holds the conventions, loaded on demand through its `adr/CLAUDE.md` shim.
- **Procedures move to skills** at `.claude/skills/<name>/SKILL.md`, loaded on demand when the task matches. The four commands became skills unchanged; five workflow skills were added (`create-branch`, `write-commit`, `debug`, `rename-symbol`, `write-ai-instructions`). All skills are model-invocable; the set is small, so their startup-context cost is low. There are no sync scripts or mirrors.
- **Subagents stay at `.claude/agents/`**: `pattern-scout`, `adr-checker`, `docs-checker`, `validate`, `research-agent`, `research-synthesizer`.
- **Three enforcement layers**, overlapping on purpose so a mistake is caught early, again at commit, and finally at the merge gate:
  1. Claude Code hooks in `.claude/settings.json` warn on generated-file edits and auto-format Dart on edit.
  2. Git-level hooks via `lefthook.yml` run the format check and `flutter analyze` before each commit.
  3. CI (`.github/workflows/pull-request-checks.yml`, job `analyze-and-test`) runs format check + analyze + tests on every PR, and the GitHub ruleset "Requirements for merge" blocks merging until that check is green.
- **ADRs are living**: one ADR per pattern, updated in place. No "superseded by" chains; history lives in git.

**Verification uses the `validate` agent, matching the shared standard's name.** It runs the format check, `flutter analyze`, and `flutter test` in the same order as CI, so a green report from it means the `analyze-and-test` merge gate will pass too. There is one verification agent, not two.

**Rejected alternative:** a standalone `CLAUDE.md` with all procedures inline. Only Claude Code reads it, and always-loaded procedures cost attention on every session even when the task does not need them; moving procedures to on-demand skills keeps the always-on map small.

## Consequences

**Positive:**

- One canonical copy of each instruction. The always-on context stays small because procedures load on demand as skills.
- A red PR can no longer merge: CI plus the ruleset form a real merge gate, and the git hooks catch problems before the PR even opens.
- No sync scripts or mirrors to maintain.

**Trade-offs and follow-up:**

- Skills, subagents, and settings are Claude-Code-only surfaces. If another agent tool is adopted, move skills to a canonical `.agents/skills/` tree with a gitignored `.claude/skills/` mirror and a sync script.
- `lefthook` is an extra tool each developer installs once (`lefthook install`). Skipping it is safe: CI still runs the same checks.
- The GitHub ruleset enforces on this repo because it is public; a private repo on the Free plan would need a paid plan for ruleset enforcement.
