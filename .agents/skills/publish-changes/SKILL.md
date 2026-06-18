---
name: publish-changes
description: Publish local changes by creating a feature branch, committing, bumping VERSION, pushing, and opening a pull request using the repository PR template. Use when the user has uncommitted changes they want to publish or asks to open a PR.
disable-model-invocation: true
---

# Publish Changes

## When to use

Trigger when the user has changes they want to publish.

## Workflow

1. Confirm uncommitted changes exist with `git status`.
2. Ask for a short branch description unless one is obvious from the changes.
3. Determine the conventional commit message and bump type from the changes:
   - `feat:` or `feat!:` → minor (major if breaking)
   - `fix:`, `chore:`, `docs:`, etc. → patch
   - `BREAKING CHANGE:` or type with `!:` → major
4. Create branch `feat/<description>` with spaces replaced by hyphens.
5. Stage and commit all changes using the conventional commit message.
6. Bump `VERSION` with `.agents/skills/publish-changes/scripts/bump-version.sh <type>`.
7. Stage `VERSION` and commit with `chore(release): bump version to <new-version>`.
8. Push the branch with `git push -u origin <branch>`.
9. Build the PR body from `.github/pull_request_template.md`, filling in the sections with a concise summary of the changes, then open the PR:
   ```bash
   gh pr create --title "<commit-subject>" --body "<filled-pr-body>"
   ```

## Bump script

Use `.agents/skills/publish-changes/scripts/bump-version.sh` to increment `VERSION`:

```bash
.agents/skills/publish-changes/scripts/bump-version.sh patch   # 1.1.0 -> 1.1.1
.agents/skills/publish-changes/scripts/bump-version.sh minor   # 1.1.0 -> 1.2.0
.agents/skills/publish-changes/scripts/bump-version.sh major   # 1.1.0 -> 2.0.0
```

## Notes

- Requires the GitHub CLI (`gh`) to be installed and authenticated.
- If `gh` is unavailable, push the branch and prompt the user to open the PR manually.
