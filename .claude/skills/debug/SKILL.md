---
name: debug
description: Root-cause a bug or a failed fix with evidence, not guesses - brainstorm causes, research them in parallel, confirm one with logs before changing code. Use when a reported behavior needs root-causing or a fix attempt has failed.
---

# Debug with evidence, not guesses

A plausible-looking cause is not enough. Turning a symptom into a fix by pattern-matching wastes a commit and loses trust. Confirm the real cause with evidence before you edit code.

1. **Brainstorm causes.** List several plausible root causes (more for a hard bug, fewer for an obvious one). Do not commit to the first idea.
2. **Research in parallel.** When the causes sit in different areas, spawn one subagent per area (a subagent is a separate agent you launch with the Agent tool) to trace that suspected code path and report whether it can actually produce the reported behavior. This keeps the files they read out of your own context. Give each subagent one focused question.
3. **Rank the causes, most likely first.** Order the surviving causes by how well they fit the evidence so far.
4. **Confirm one with targeted logs, in that order.** For the top cause, add a log line (use `Debug.log` / `Debug.logError` from `flutter_essentials/`), or a breakpoint, or a small `flutter test` that would prove or disprove it, run the failing path, and read the output. Move to the next cause only after the current one is disproven. Never change logic on a theory you have not confirmed.
5. **Match the fix to the confirmed cause.** Fix exactly what the evidence points to. If the change you want to make does not address the confirmed symptom, say so and ask first; do not slip a "nice-to-have" in as a bug fix.
6. **Broaden if every theory fails.** The same symptom can come from outside the obvious code: stale generated code (re-run `cd menu_management && dart run build_runner build --delete-conflicting-outputs`), a Freezed model changed without regenerating, stale provider state not refreshed with `notifyListeners()`, loaded `.tsr`/`.tsm` data that does not match the current model shape, desktop platform quirks (Windows `FilePicker`, `audioplayers` native deps), and less-obvious code paths. Keep investigating; do not stop at the first dead end.

Remove the logs you added once the cause is confirmed.
