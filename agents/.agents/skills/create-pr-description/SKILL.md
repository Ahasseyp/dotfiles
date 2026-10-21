---
name: create-pr-description
description: Generate a pull request description by analyzing git diffs against a target branch. Follows the project's PULL_REQUEST_TEMPLATE.md format with all required sections. Use when the user asks to create a PR description, write a PR summary, describe changes for a pull request, or prepare a PR body.
---

# Create PR Description

## Principles

PR descriptions are read by QA and product, not just engineers. Keep them concise, proofread, and free of AI bloat. Trim unnecessary verbosity and avoid technical noise — file names, component names, and test commands (e.g. `yarn test`) — unless a specific case truly requires it. A tidy, product-driven description beats an exhaustive one.

## Workflow

### Step 1: Determine the target branch

Default to `main`. Only use a different branch if the user explicitly provides one.

### Step 2: Read the PR template

Read `PULL_REQUEST_TEMPLATE.md` from the project root. If it doesn't exist, use the default template from [template.md](template.md).

### Step 3: Get the ticket number

Run `git branch --show-current` and parse the Jira ticket identifier (e.g., `PARA-1234`) from the branch name. The branch format is `{type}/{ticket}/{description}`.

### Step 4: Collect and analyze changes

Run these in parallel:
- `git diff {target_branch}` for the full diff
- `git diff {target_branch} --stat` for a summary of changed files
- `git status` to understand scope

For every changed file, read enough context (imports, types, callers) to understand intent and impact. Classify each change:
- New files added
- Files renamed or moved
- Files modified (and the nature of the changes)
- Files deleted

### Step 5: Generate the PR title

Create a concise PR title following the commit format: `type(scope): {brief description}`

- `type` is the conventional commit type derived from the nature of the changes (e.g., `feat`, `fix`, `chore`, `refactor`, `docs`)
- `scope` is the affected service(s) derived from the changed files (e.g., `dashboard`, `hermes`). When changes span multiple services, list them comma-separated: `type(service1,service2): {brief description}`. Omit scope only if no clear scope exists, using `type: {brief description}` instead
- `{brief description}` is a lowercase imperative phrase summarizing the change (e.g., `add retry logic to webhook delivery`)
- Keep it under 72 characters total
- Use imperative mood (add, fix, update, remove — not added, fixed, updated)

### Step 6: Generate the description

Produce a copyable markdown PR description following **every section** from the template in order:

1. **Issues Closed** - Use the Jira ticket from the branch name
2. **Brief Summary** - 10 words or less, lowercase
3. **Detailed Summary** - Short and direct: what was done and why, a few sentences at most
4. **Changes** - Bullet list of each meaningful change. Do NOT list `spec`/test files — their intent is obvious
5. **Unrelated Changes** - Anything not in the Jira ticket scope
6. **Future Work** - Default to none. Only include an item if it genuinely warrants a Jira ticket; if so, create the ticket, describe it, and link it here. If it isn't worth a ticket, write `N/A`
7. **Steps to Test** - For user-facing changes (e.g. `dashboard`), write product/QA-driven steps as a clear user-facing flow, avoiding file names, component names, and test commands (e.g. `yarn test`). For changes with no user-facing surface (backend/internal microservices), write the clearest realistic verification path for QA, which may legitimately be technical (API request + expected response, payload/log/DB check). Either way, keep it concise and skip incidental implementation details
8. **QA Notes** - Special considerations for QA
9. **Deployment Notes** - Config changes, migrations, env vars
10. **Screenshots** - For any visual change, always include screenshots (add a placeholder and prompt the user to attach them if not available)

## Output Rules

- Return the PR title first, clearly labeled, followed by the description
- Return the description as a single copyable markdown block
- Do NOT create any files
- Be concise and proofread: trim AI verbosity rather than maximizing detail. Every section should earn its place
- Never leave a section blank. If a section (e.g. Unrelated Changes, Future Work, QA Notes, Deployment Notes) has no relevant content, write `N/A` under it
- Accurately represent the nature of each change (addition, rename, modification, deletion)
