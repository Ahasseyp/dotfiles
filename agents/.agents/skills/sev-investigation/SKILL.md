---
name: sev-investigation
description: Investigate a BetterStack/k8s alert Richard-Watson style and draft the dev-investigation Slack post. Provide a Slack alert link, a SEV channel link, and a kubectl-status markdown file.
disable-model-invocation: true
---

Investigate the way Richard Watson does: **evidence-first**. Every claim is either confirmed evidence (with a source) or a hypothesis. When incident-time evidence is missing, the finding is a gap — state it instead of inventing a root cause. Keep this discipline in the analysis; in the Slack post itself, write plainly without meta-labels like "confirmed" or "hypothesis (labeled)".

## Inputs

Ask for any that are missing:

1. Slack link to the BetterStack alert thread (usually in `#dev-oncall-alerts`)
2. Slack link to the SEV channel
3. Path to the `kubectl-status.sh` markdown output file (optional, see below)

Done when: the alert channel + timestamp and the SEV channel ID are resolved, and the kubectl-status question is settled one way or another.

### The kubectl-status file is optional

The script only applies to on-prem / EKS customer installations. It does not apply to Cloud Production (ECS, `paragon-env-production-cluster`) or the Sentry observability cluster, so skip it entirely for those.

If the alert is on a customer installation and no file was provided, don't block on it. Check whether kubectl access to that cluster is already configured (`kubectl config current-context`). If yes, run it yourself:

```bash
./kubectl-status.sh <customer> <service>
```

If you can't run it, tell the user the exact command with the customer and service filled in, ask them to run it and share the markdown output, and continue the rest of the investigation (Slack catch-up, BetterStack incident review, external checks) in the meantime instead of stalling.

## 1. Read the alert

`slack_read_thread` on the alert link. Extract:

- Service and customer installation (or Cloud Production)
- Platform: EKS customer cluster, ECS (`paragon-env-production-cluster`), or the Sentry observability cluster
- Severity and alert type (health check 5xx, restarts, HPA maxed, nodes NotReady, Redis backlog, …)
- BetterStack incident and monitor URLs

Done when: you have a one-line alert summary with each field filled or marked "not stated".

## 2. Catch up

Read the SEV channel's dev investigation thread fully (and the on-call alerts thread if one exists). Then search recent SEV channels and Jira for the same symptom in the last few days.

Done when: you can state what is known, what has been tried, and the open questions. If a recent SEV covers the same symptom, propose canceling as a duplicate with a link to the existing channel. If the thread already has a confirmed root cause, skip to step 6 and draft a follow-up post instead of re-investigating.

## 3. Analyze the kubectl-status file

Skip this step if the alert is not on a customer installation or the file isn't available (see Inputs). Otherwise read the markdown file. Account for every non-healthy row:

- Restarts: exit code **and** reason — exit 137 with reason `Error` is a probe-failure kill, a different investigation than `OOMKilled`
- Pending pods and why (Insufficient cpu/memory, Too many pods)
- HPA at max: compare request vs. limit vs. observed usage — the HPA target is a percentage of *request*
- Nodes NotReady or SchedulingDisabled

Done when: every non-healthy row in the file has an explanation or a concrete follow-up check.

## 4. Branch by alert type

Read [`reference/decision-tree.md`](reference/decision-tree.md), find the row matching the alert, and run its checks. Command snippets live in [`reference/commands.md`](reference/commands.md). For worked examples of each alert type, see the case studies in `/Users/alberthassey/Documents/paragon/dev-utils/support/output/sev-investigation-patterns-richard-watson.md`.

Done when: every check in the matching row has a result, or "could not run — need \<access or command\>".

## 5. Build the timeline

Correlate alert time, restarts/evictions, deploys, and recovery. Normalize everything to UTC.

Done when: you have an ordered timeline where every entry names its source (BetterStack incident, k8s events, ECS stopped tasks, pod logs).

## 6. Draft the post

Read [`reference/richard-voice.md`](reference/richard-voice.md) and write the dev-investigation post in Richard's voice. Keep it brief and direct: a one-line current-state summary and a short bullet list of the evidence (each with a source). The post conveys information and evidence only. Do not include:

- Meta-labels like "Confirmed facts", "Hypothesis (labeled)", or "indeterminate" — state what is measured plainly; if something is unproven, phrase it as a plain possibility ("this looks like...", "possibly...") rather than labeling it
- Follow-ups, tickets, owners, or priorities
- A timeline table or minor observations

Run the draft through the humanizer skill before posting it: no em dashes, no formulaic structure, plain sentences.

Done when: the draft is short enough to skim in under a minute, reads like a person wrote it, and every claim traces to a source. Follow-ups, tickets, owners, and priorities are NOT in the post.

## 7. Deliver

Give the user an ordered list of what to do next (commands to run, people to ping, mitigations to consider) — this is where all follow-ups, proposed tickets, owners, and priorities go; they are for the user only, not the Slack post. Then post the draft into the dev investigation thread with `slack_send_message_draft` so the user can review it. Send only after the user approves.

Done when: the user has the action list (including follow-ups) and the draft is posted to the thread.
