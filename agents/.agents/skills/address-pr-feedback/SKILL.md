---
name: address-pr-feedback
description: Walk every comment on the current branch's PR, apply or decline each one, and draft the reply comments.
disable-model-invocation: true
---

Address every piece of feedback on the current branch's open PR, one comment at a time, then produce the reply comments as copyable markdown.

## Process

### 1. Resolve the PR

Run `gh pr view --json number,title,url` for the current branch. If no open PR exists, stop and say so.

### 2. Fetch the feedback

Collect inline review comments and review-summary bodies:

- `gh api repos/{owner}/{repo}/pulls/{n}/comments` for inline threads.
- `gh api repos/{owner}/{repo}/pulls/{n}/reviews` for review bodies.

Keep only comments from humans and `paragonbot`. Drop other bots, already-resolved threads, and your own replies. Completion criterion: every kept comment is in one ordered list, PR-chronological, with its comment ID, author, file/hunk, and body. State the total count before starting.

Also collect the user's own past replies on the PR (filter the same comments payload by the user's login); if the PR has none, pull the user's replies from a recent previous PR. Hold these aside as the voice sample for step 4 — they are not feedback to address.

### 3. Walk the comments

For each comment, in order:

1. **Present it** — author, file/hunk, the comment body, and your verdict with 1–2 sentences of reasoning. Read the actual code before judging. Three verdicts:
   - **valid** — the concern is real and actionable.
   - **invalid** — the concern is wrong, already handled, or a misunderstanding.
   - **unclear** — ambiguous, or depends on context you can't see.

2. **Ask an interactive multiple-choice question** (the agent's question mechanism, not plain text). Options by verdict:
   - valid → 2–4 concrete fix options, each a specific action with a one-line trade-off, one marked "(Recommended)" with a sentence on why; plus "This is actually invalid/unclear".
   - invalid → "Decline and draft the reply" (Recommended when the reasoning holds); plus "This is actually valid — show me fixes".
   - unclear → "Ask the reviewer a clarifying question" (Recommended); plus reclassify to valid or invalid.
   - Every comment also gets "Skip this comment" and "Stop the walkthrough".

3. **Wait for the choice.** No batching, no auto-advancing.

4. **Apply the chosen fix immediately** when one was chosen. Confirm with files touched and a one-line description. If the fix fails or needs broader refactoring, say so, offer to narrow it or record it as follow-up, and move on only after the user agrees. Never commit.

5. **Log the decision**:

   ```
   Comment #<n> (<author>, <file>): <short description>
   Verdict: <valid | invalid | unclear>
   Outcome: <fix applied | declined | clarifying question | skipped>
   Files touched: <paths or "none">
   ```

Completion criterion: every comment in the list has a logged outcome.

### 4. Draft the replies

From the decision log, write one reply per comment:

- **Addressed** — one sentence: what was done and where. "Fixed — extracted the shared helper into `utils/format.ts`."
- **Declined** — up to two sentences: the why. A decline without a reason reads as dismissive.
- **Unclear** — one short clarifying question.
- **Skipped** — no reply unless the user asks for one.

Voice rules, derived from the user's posted replies:

- Lead with the action, past tense, first word carries it: "Dropped the whole file.", "Spreads are gone.", "Renamed to `useDebouncedValue`."
- Default to one sentence; two max. Cut any sentence the reviewer doesn't need to understand or verify the fix.
- Justify only when the fix isn't the obvious read of the comment (e.g. keeping z-index but scoping it with `isolate`), or when partially pushing back. Obvious fixes get no reasoning.
- No credit or flattery ("You called it", "Good catch"), no thanks, no "Thanks for the pointer".
- No tie-in context the reviewer didn't ask about ("matching the other dialogs"). Keep only if it signals a durable convention change, like a `CODING_STANDARDS.md` update.
- Backtick identifiers, file names, and symbols; plain casual tone, contractions fine.
- When a fix was discussed and chosen in the walkthrough, "Addressed!" plus one short clause is acceptable.

Then run the full markdown block through the `humanizer` skill in embedded mode (final text only, no draft or audit), passing the voice sample from step 2 as the Voice Calibration sample so it matches the user's habits instead of applying default de-AI rules. The replies go out under the user's name — they must read like the user wrote them.

### 5. Present, then offer to post

Present the final replies one at a time, in PR order: each reply gets a file/hunk label and its own fenced markdown block so it can be copied individually. No single combined block. Then ask an interactive yes/no: post each reply as a threaded response via `gh api repos/{owner}/{repo}/pulls/comments/{id}/replies -f body="..."`. If yes, post and report which succeeded. Never resolve threads — the reviewer resolves their own.
