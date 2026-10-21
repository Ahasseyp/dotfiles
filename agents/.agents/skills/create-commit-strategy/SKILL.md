---
name: create-commit-strategy
description: Analyze git diffs and generate a commit strategy that logically groups related changes into separate commits. Optionally executes the plan after user confirmation. Use when the user asks to create a PR strategy, plan commits, group changes into commits, organize a diff for committing, or prepare changes for a pull request.
---

# Create Commit Strategy

Generate a commit plan from the current git diff, then optionally execute it.

> **Sandbox:** Every shell command in this skill must be run with `required_permissions: ["all"]`
> to ensure git operations have full filesystem access and are not blocked by the sandbox.

## Step 1: Gather the Diff

Run all of these commands **in parallel** to collect the current state:

```bash
git status
git diff --stat HEAD
git diff HEAD
git ls-files --others --exclude-standard
```

If untracked files are reported, read their contents so they can be included in the grouping analysis — `git diff HEAD` does not surface untracked files.

## Step 2: Resolve Types, Scopes, and Ticket

### Allowed types

Try to read the root `package.json` and look for `config.validate-commit-msg.types`. Use that array as the allowed commit types.

If `package.json` does not exist or the key is absent, fall back to: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`, `style`, `perf`, `ci`, `build`.

### Allowed scopes

Try to read the root `package.json` and look for `config.validate-commit-msg.scope.allowed`. Use that array as the allowed scopes.

If `package.json` does not exist or the key is absent, infer scope from the files being changed using the top-level workspace folder name (e.g. `workers/worker-actions/...` -> `worker-actions`, `microservices/dashboard/...` -> `dashboard`, `packages/utils/...` -> `utils`). If all changed files live at the repository root with no distinguishing subdirectory, omit scope from the commit message format (use `type: message` instead of `type(scope): message`).

### Ticket ID

Extract a Jira-style ticket ID from the current branch name:

```bash
git branch --show-current
```

Match the pattern `[A-Z]+-\d+` (e.g. `PARA-1234`).

If the branch contains a ticket ID, include it in the plan.

If **no ticket is found**, use the AskQuestion tool to ask the user:

- Option 1: **Provide ticket ID** — the user supplies a ticket ID manually
- Option 2: **Skip — no ticket** — proceed without a ticket

Do not silently skip the ticket.

## Step 3: Plan the Commit Strategy

**Fast path:** If the diff is a single logical change across 1-3 files, skip the planning checklist and propose one commit directly. Jump to Step 4.

For larger diffs, produce a concise rationale (3-7 bullets) describing the planned grouping approach before assigning any files. This is an internal reasoning step — it is not shown to the user — and helps catch bad groupings early.

### Grouping Rules

- Review both the file list and the actual diffs to determine which changes are related.
- Group closely connected files into a single commit.
- Before assigning files, state in one line the purpose and minimal criteria for each group.
- After forming each group, validate in 1-2 lines that the files are logically associated and the message accurately summarizes the changes.
- Self-correct if validation fails.
- When a single file has changes that logically belong to two different groups, assign the file to the group where it has the most substantive changes. Do not attempt partial-file staging (`git add -p`).
- Each commit should leave the repo in a buildable, lintable state when possible. Avoid groupings that would cause intermediate commits to break imports, types, or tests.

### Commit Message Format

Each message must follow: `type(scope): message`

- `type` must be one of the allowed types resolved in Step 2.
- `scope` must be one of the allowed scopes resolved in Step 2. If no scope was resolved, use `type: message` instead.
- Messages must be under 100 characters.

### Ordering

Order commits to reflect logical progression of changes. Infrastructure and dependency changes come first, followed by implementation, then tests and documentation.

## Step 4: Present the Plan

Lead with a summary line, then output the plan as a markdown list:

```markdown
**3 commits planned:**

- **Commit 1:** `feat(dashboard): add login functionality`

  **Ticket:** `PARA-1234`

  **Files (2):**
  - login.js
  - auth.js

- **Commit 2:** `fix(hermes): correct webhook retry logic`

  **Files (1):**
  - webhook.js

- **Commit 3:** `test(hermes): add webhook retry tests`

  **Files (1):**
  - webhook.test.js
```

Omit the **Ticket** line for commits where no ticket was resolved.

If the diff is empty or malformed, report that clearly and stop.

## Step 5: Ask for Confirmation

After presenting the plan, ask the user to confirm before executing. Use the AskQuestion tool:

- Option 1: **Execute** — stage and commit each group as planned
- Option 2: **Edit** — the user describes what to change; revise the plan and re-present from Step 4
- Option 3: **Abort** — do nothing, let the user adjust manually

Do NOT execute without explicit confirmation.

## Step 6: Execute the Plan

Before starting, warn the user that the staging area will be reset (`git reset HEAD`) so that files can be staged per-group. If the user had intentionally staged files, they should be aware this will unstage them.

### 6a: Create a Backup Tag

Run the following steps in sequence to snapshot the current working state before touching any commits:

1. Create a WIP commit wrapping all staged/unstaged changes:

   ```bash
   git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"
   ```

2. Create a lightweight local tag pointing at that WIP commit:

   ```bash
   git tag backup/<current-branch>-$(date +%Y%m%d-%H%M)
   ```

   Use the branch name resolved in Step 2 in place of `<current-branch>`. Store the resulting tag name — you will need it for cleanup and error recovery.

3. Revert the WIP commit, restoring the working tree exactly as it was:

   ```bash
   git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1
   ```

> **Note:** This tag is local only. It is not pushed by a plain `git push`. Do not run `git push --tags` or `git push origin backup/*` at any point in this skill.

### 6b: Commit Each Group

For each commit group in order:

1. Reset the staging area: `git reset HEAD` (only before the **first** commit)
2. Stage only the files for this group: `git add <file1> <file2> ...`
3. Commit using a HEREDOC to safely handle special characters:
   - With ticket:

     ```bash
     git commit -m "$(cat <<'EOF'
     type(scope): message

     TICKET-ID
     EOF
     )"
     ```

   - Without ticket:
     ```bash
     git commit -m "$(cat <<'EOF'
     type(scope): message
     EOF
     )"
     ```

### 6c: Clean Up the Backup Tag

After **all** commits succeed, delete the backup tag:

```bash
git tag -d <backup-tag>
```

Then run `git log --oneline -n <number_of_commits>` to confirm the result and show it to the user.

### Error Handling

- If a file in the plan no longer has changes (already committed in a prior group), skip it and inform the user which file was skipped and why.
- If `git add` or `git commit` fails, stop execution and report the error. Do **not** delete the backup tag. Tell the user the backup tag name and how to recover:

  > Backup tag `<backup-tag>` was preserved. To restore your original state, run:
  > ```
  > git reset --hard <backup-tag>
  > git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1
  > git tag -d <backup-tag>
  > ```

- If a pre-commit hook modifies files (e.g. auto-formatting), subsequent `git add` calls may pick up unintended changes. When a commit fails or a hook rewrites files, report this to the user before proceeding.

## Edge Cases

- **Empty diff:** If `git diff HEAD` produces no output and there are no untracked files, inform the user there is nothing to commit and stop.
- **Trivial diff:** If the diff is a single logical change across 1-3 files, skip the planning ceremony — propose one commit directly and move to Step 5.
- **Large diff (50+ files):** Warn the user that the diff is large. Suggest limiting scope (e.g. committing a subset now) or confirm they want a strategy for the full diff before proceeding.
- **Partial file staging:** This skill stages whole files only. If a single file contains changes that belong to different logical groups, assign the file to the group where it has the most substantive changes (see Step 3). Do not use `git add -p`.
