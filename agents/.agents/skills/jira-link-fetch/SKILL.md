---
name: jira-link-fetch
description: Fetch Jira issue details including custom fields (Acceptance Criteria, Background or Technical Notes, Steps to Test) whenever a Jira link is shared. Use when a useparagon.atlassian.net/browse/ URL appears in the conversation.
---

# Jira Link Fetch

When a `useparagon.atlassian.net/browse/PARA-XXXX` URL is shared, delegate the fetch to the `jira-fetch` subagent before responding, then relay its summary.

## Delegate to the jira-fetch subagent

Extract the issue key from the URL (e.g. `PARA-19233`) and spawn the `jira-fetch` subagent via the Task tool:

- `subagent_type`: `jira-fetch`
- `description`: `Fetch Jira ticket`
- `model`: `composer-2.5-fast`
- `readonly`: `false` — required so the subagent has MCP access (readonly subagents cannot use MCP)
- `prompt`: instruct the subagent to call `getJiraIssue` on the `user-atlassian-rovo-mcp` server and return ONLY the Output Format block below, with the following arguments:
  - `cloudId`: `f25fd3e2-c93b-4c7f-bcea-d3027d2fa860`
  - `issueIdOrKey`: the extracted key
  - `responseContentFormat`: `"markdown"`
  - `fields`:
    ```
    [
      "summary",
      "description",
      "status",
      "priority",
      "assignee",
      "issuetype",
      "labels",
      "comment",
      "customfield_10146",
      "customfield_10144",
      "customfield_10054"
    ]
    ```

When multiple Jira URLs are shared, spawn one `jira-fetch` subagent per ticket key.

After the subagent returns, relay its summary to the user.

Custom field reference (pass these to the subagent):
| Field ID | Name |
|---|---|
| `customfield_10146` | Acceptance Criteria |
| `customfield_10144` | Background or Technical Notes |
| `customfield_10054` | Steps to Test |

## Output Format

The subagent must return its summary in this exact structure (no files), and the main agent relays it directly in chat:

```
**[PARA-XXXX] <summary>**
**Type:** <issuetype> | **Status:** <status> | **Priority:** <priority>
**Assignee:** <assignee>

**Description**
<description>

**Background or Technical Notes**
<customfield_10144>

**Acceptance Criteria**
<customfield_10146>

**Steps to Test**
<customfield_10054>
```

Omit any section whose value is null or empty.
