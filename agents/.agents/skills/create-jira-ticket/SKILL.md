---
name: create-jira-ticket
description: Generate a Jira task description from a git diff, PR description, or engineering spec — then create it directly in Jira via the Atlassian MCP. Supports Task, Bug, and Spike types. Use when the user asks to create a Jira ticket, write a task description, or generate a ticket from a diff, branch, or spec.
---

# Create Jira Ticket

Generate a structured Jira ticket from a git diff or engineering spec, then create it directly in Jira using the `plugin-atlassian-atlassian` MCP.

## Step 1 — Determine the Source

Ask the user which source to use:

- **Git diff**: Ask for the target branch name, then run `git diff {target_branch}...HEAD`.
- **Spec**: Ask the user to provide or reference the spec (Notion page, markdown file, or pasted text).

## Step 2 — Determine the Ticket Type

Ask the user (or infer from context) whether this is a **Task**, **Bug**, or **Spike**.

- **Task**: A standard engineering work item with clear deliverables.
- **Bug**: A defect or unintended behavior that needs to be fixed.
- **Spike**: A time-boxed investigation to answer open questions or reduce uncertainty.

## Step 3 — Collect Project Key

Ask the user for the Jira project key if not already known. Default to `PARA`.

If the user is unsure, call `getVisibleJiraProjects` with `cloudId="f25fd3e2-c93b-4c7f-bcea-d3027d2fa860"` to list available projects.

## Step 4 — Analyze the Source and Generate Content

Analyze the source and generate all required fields for the ticket type. At the same time, **infer suggested values** for the three shared option fields based on context. Output everything as a preview using fenced markdown blocks — one block per field — so each can be reviewed and edited before creation.

### Inferring Shared Option Fields

The suggested value for each option field **must be an exact string from the catalog below** — do not invent or paraphrase values.

---

**Feature Category** (`customfield_10710`)

Pick the single best match from this exact catalog based on the area of the codebase or feature being changed:

| If the change involves… | Suggest |
|---|---|
| Login, session, or identity | `Auth` |
| OAuth provider flows | `OAuth` |
| OAuth trigger/webhook authentication | `OAuth Trigger` |
| MFA / two-factor | `MFA` |
| Stored credentials or secrets | `Credential` |
| Refreshing credentials | `Refresh Credential` |
| Connect credential management | `Connect Credential` |
| Third-party integrations | `Integration` |
| Integration configuration | `Integration Config` |
| Enabling/disabling integrations | `Integration Enabled` |
| Workflow definition or execution | `Workflow` |
| Workflow execution runtime | `Workflow Execution` |
| Workflow migration | `Workflow Migration` |
| Workflow tags | `Workflow Tag` |
| Individual step logic | `Step` |
| Step execution | `Step Execution` |
| Billing or payments | `Billing` |
| Organization or team management | `Organization` |
| Team membership | `Team Member` |
| Team settings | `Team` |
| User accounts or profiles | `User` |
| Invitations | `Invite` |
| API keys | `API Key` |
| Signing keys | `Signing Key` |
| Project signing keys | `Project Public Signing Key` |
| Master keys | `Master Key` |
| Secrets management | `Secret` |
| Security posture / hardening | `Security` |
| Webhooks (inbound triggers) | `Webhook Trigger` |
| Request triggers | `Request Trigger` |
| Custom webhook triggers | `Custom Webhook Trigger` |
| Cron/scheduled triggers | `Cron Trigger Subscription` |
| Event destinations | `Event Destination` |
| Event logs or audit trails | `Event Logs` |
| Audit logs | `Audit Logs` |
| Feature flags | `Feature Flag` |
| Rate limiting | `Smart Rate Limits (SRL)` |
| Throttling | `Throttling` |
| Caching / replay | `Cache Replay` |
| Managed sync | `Managed Sync` |
| Datastores / Postgres | `Datastores - Postgres` |
| Task history | `Task History` |
| Admin UI or internal admin tooling | `Admin` |
| Analytics / metrics | `Analytics` |
| Deployment pipelines | `Deployment` |
| Kubernetes / infrastructure | `Infra - Kubernetes` |
| AWS infrastructure | `Infra - AWS` |
| GCP infrastructure | `Infra - GCP` |
| Azure infrastructure | `Infra - Azure` |
| Docker / containers | `Infra - Docker` |
| Observability / monitoring | `Infra - Observability` |
| Install or upgrade processes | `Infra - Install / Upgrade` |
| GitHub / CI automation | `Internal - GitHub` |
| QA automation | `Internal - QA Automation` |
| Administrative/internal work | `Internal - Administrative` |
| Connect UI/SDK | `Connect UI` or `Connect SDK` |
| Connect proxy | `Connect Proxy` |
| Connect sandbox | `Connect Sandbox` |
| BYO (Bring Your Own) features | `BYO` |
| ActionKit | `ActionKit` |
| TriggerKit | `TriggerKit` |
| Personas | `Persona` |
| Projects | `Project` |
| Resources | `Resource` |
| Test workflows | `Test Workflow` |
| Tutorials / onboarding | `Tutorial` |
| Release management | `Release` |
| App events | `App Event` |
| Embassy services (analytics/auth/billing/license) | `Embassy Analytics` / `Embassy Auth` / `Embassy Billing` / `Embassy License` |
| Inner Circle / partner programs | `Inner Circle` |
| Dashboard global config | `Dashboard - Global Config` |
| Infoz / healthz endpoints | `Infoz` / `Healthz` / `Ping` |
| Stats | `Stats` |
| Graphite / Grafana | `Graphite` / `Grafana` |
| Paragraph | `Paragraph` |

---

**Work Category** (`customfield_10711`)

Must be one of these exact strings:

| If the work is… | Suggest |
|---|---|
| A new product feature or user-facing capability | `Roadmap / Business Feature` |
| Internal tooling, process, or infrastructure improvement | `Operational / Internal Improvement` |
| A bug fix, refactor, or tech debt cleanup | `Defect / Tech Debt / Refactor` |
| Learning, research, or a Spike | `Professional Development` |
| Customer-facing sales/revenue enablement | `Revenue Enablement` |

---

**Execution Priority** (`customfield_10712`)

Must be one of these exact strings. Default conservatively:

| Context | Suggest |
|---|---|
| Active incident or P0 | `01 - Active P0 / SEV` |
| Prevention of a potential SEV | `02 - SEV Prevention` |
| Roadmap item with SLA risk or breach | `03 - Roadmap SLA Risk/Breached` |
| Support SLA risk or breach | `04 - SUP SLA Risk/Breached` |
| Operational process work | `05 - Operational Process` |
| Long-term SEV refactor | `06 - SEV Refactor (Long-term)` |
| Standard roadmap task or Spike | `07 - Roadmap Non-SLA` |
| Bug or improvement (default for Bugs) | `08 - Bugs / Improvements` |
| Operational improvement (default for Operational work) | `09 - Operational Improvement` |

---

### Output Format — Task

**Title**
```
[One-line summary, under 80 characters]
```

**Description**
```
[1–2 sentence explanation of the task]
```

**Acceptance Criteria**
```
- [Specific, verifiable outcome]
- [Specific, verifiable outcome]
```

**Background**
```
[Context on why this work is needed. Write "N/A" if none.]
```

**Steps to Test**
```
1. [Concrete, reproducible step]
2. [Concrete, reproducible step]
```

**Feature Category** *(suggested — must be an exact value from the catalog above)*
```
[exact catalog value]
```

**Work Category** *(suggested — must be an exact value from the catalog above)*
```
[exact catalog value]
```

**Execution Priority** *(suggested — must be an exact value from the catalog above)*
```
[exact catalog value]
```

---

### Output Format — Bug

**Title**
```
[One-line summary, under 80 characters]
```

**Description**
```
[1–2 sentence explanation of what is broken]
```

**Current Behavior**
```
[What is currently happening — the broken behavior]
```

**Expected Behavior**
```
[What should happen instead]
```

**Acceptance Criteria**
```
- [Specific, verifiable outcome]
```

**Background**
```
[Context on when this was introduced or discovered. Write "N/A" if none.]
```

**Steps to Test**
```
1. [Step to reproduce or verify the fix]
2. [Step to reproduce or verify the fix]
```

**Feature Category** *(suggested — must be an exact value from the catalog above)*
```
[exact catalog value]
```

**Work Category** *(suggested — must be an exact value from the catalog above)*
```
Defect / Tech Debt / Refactor
```

**Execution Priority** *(suggested — must be an exact value from the catalog above)*
```
08 - Bugs / Improvements
```

---

### Output Format — Spike

**Title**
```
Spike: [One-line summary of what is being investigated]
```

**Description**
```
[1–2 sentence explanation of what needs investigating and why]
```

**Background or Technical Notes**
```
[Context on why this investigation is needed. Include any relevant prior art, constraints, or known information.]
```

**Acceptance Criteria**
```
- [What "done" looks like — e.g. "Decision documented", "PoC created", "Engineering spec written"]
```

**Questions**
```
- [Specific, answerable question the spike should resolve]
- [Specific, answerable question the spike should resolve]
```

**Feature Category** *(suggested — must be an exact value from the catalog above)*
```
[exact catalog value]
```

**Work Category** *(suggested — must be an exact value from the catalog above)*
```
[exact catalog value]
```

**Execution Priority** *(suggested — must be an exact value from the catalog above)*
```
07 - Roadmap Non-SLA
```

---

## Step 5 — Confirm and Create

After presenting the preview, ask:

> "Should I create this ticket in Jira? Feel free to edit any fields above before confirming."

### ADF Format for Custom Fields

All free-text custom fields in `additional_fields` must be passed as ADF (Atlassian Document Format) JSON objects — not raw strings. The Jira API rejects plain text for these fields.

Use these three templates depending on content shape:

**Paragraph** — for single-block text (Description, Background, Current Behavior, Expected Behavior):
```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [{"type": "text", "text": "your text here"}]
    }
  ]
}
```

**Bullet list** — for bullet-point content (Acceptance Criteria, Questions):
```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [{"type": "paragraph", "content": [{"type": "text", "text": "item one"}]}]
        },
        {
          "type": "listItem",
          "content": [{"type": "paragraph", "content": [{"type": "text", "text": "item two"}]}]
        }
      ]
    }
  ]
}
```

**Ordered list** — for numbered steps (Steps to Test):
```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "orderedList",
      "content": [
        {
          "type": "listItem",
          "content": [{"type": "paragraph", "content": [{"type": "text", "text": "step one"}]}]
        },
        {
          "type": "listItem",
          "content": [{"type": "paragraph", "content": [{"type": "text", "text": "step two"}]}]
        }
      ]
    }
  ]
}
```

Option fields (`customfield_10710`, `customfield_10711`, `customfield_10712`) use `{"value": "..."}` — no ADF needed for those.

---

On confirmation, create the ticket using `createJiraIssue` from `plugin-atlassian-atlassian`:

**Task:**
```json
createJiraIssue(
  cloudId="f25fd3e2-c93b-4c7f-bcea-d3027d2fa860",
  projectKey="PARA",
  issueTypeName="Task",
  summary="[Title]",
  additional_fields={
    "customfield_10054": <orderedList ADF with Steps to Test>,
    "customfield_10146": <bulletList ADF with Acceptance Criteria>,
    "customfield_10710": {"value": "[Feature Category]"},
    "customfield_10711": {"value": "[Work Category]"},
    "customfield_10712": {"value": "[Execution Priority]"}
  }
)
```

**Bug:**
```json
createJiraIssue(
  cloudId="f25fd3e2-c93b-4c7f-bcea-d3027d2fa860",
  projectKey="PARA",
  issueTypeName="Bug",
  summary="[Title]",
  description="[Description]",
  contentFormat="markdown",
  additional_fields={
    "customfield_10054": <orderedList ADF with Steps to Test>,
    "customfield_10080": <paragraph ADF with Current Behavior>,
    "customfield_10083": <paragraph ADF with Expected Behavior>,
    "customfield_10146": <bulletList ADF with Acceptance Criteria>,
    "customfield_10710": {"value": "[Feature Category]"},
    "customfield_10711": {"value": "[Work Category]"},
    "customfield_10712": {"value": "[Execution Priority]"}
  }
)
```

**Spike:**
```json
createJiraIssue(
  cloudId="f25fd3e2-c93b-4c7f-bcea-d3027d2fa860",
  projectKey="PARA",
  issueTypeName="Spike",
  summary="[Title]",
  additional_fields={
    "customfield_10144": <paragraph ADF with Background or Technical Notes>,
    "customfield_10145": <bulletList ADF with Questions>,
    "customfield_10146": <bulletList ADF with Acceptance Criteria>,
    "customfield_10710": {"value": "[Feature Category]"},
    "customfield_10711": {"value": "[Work Category]"},
    "customfield_10712": {"value": "[Execution Priority]"}
  }
)
```

Notes:
- For Task and Spike, `description` is not a required field — do not pass it.
- For Bug, `description` is a top-level MCP field and accepts markdown via `contentFormat="markdown"`.
- The `contentFormat` parameter does **not** affect `additional_fields` — ADF must be constructed explicitly for each custom field.

## Step 6 — Report the Result

After successful creation, output:

```
Ticket created: PARA-XXXX — [summary]
https://useparagon.atlassian.net/browse/PARA-XXXX
```

---

## Writing Guidelines

- Write clearly and concisely — just enough context for another engineer to understand the what, why, and how.
- Acceptance Criteria should be specific and verifiable, not vague.
- Steps to Test (Tasks/Bugs) should be concrete and reproducible.
- Questions (Spikes) should be specific and answerable — avoid open-ended or philosophical questions.
- For git diffs: if the diff is large, group related changes and summarize rather than listing every file.
- For specs: distill the relevant scope into a single focused task — do not restate the entire spec.
- Suggest conservative execution priorities unless the source clearly indicates urgency.
