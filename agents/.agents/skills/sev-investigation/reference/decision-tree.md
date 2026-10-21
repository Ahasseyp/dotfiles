# Decision tree: given this alert, run these checks

Find the row matching the alert. Run every check in it; each gets a result or "could not run — need \<access or command\>". Command snippets are in [`commands.md`](commands.md).

| Alert signal | Checks |
| --- | --- |
| Health check 5xx | Response headers (`server: awselb/2.0` means the 5xx came from the ALB, not the app); resolved IP; BetterStack incident timeline; pod/target health |
| Timeout / "no headers received" | `http GET <endpoint>/healthz` from outside; pod status; OOMs, evictions, autoscaling limits, Spot capacity |
| ECS service alert | `aws ecs describe-services --include TAGS`; stopped-task exit codes and reasons; Spot weighting; ENI rate limits; autoscaling max |
| K8s pod restarts | `kubectl get pods -o wide`, `describe pod`, `get events`; exit 137 `Error` vs `OOMKilled`; liveness probe timeouts; log silence before the kill; memory/CPU burst pattern |
| HPA maxed out | `kubectl top pods`, `kubectl get hpa`; request vs. limit vs. observed RSS/CPU; baseline usage pinning vs. real load spike |
| Sentry service (observability cluster) | `kubectl -n sentry get pods/events`, `logs --since=45m`; evictions (`Forceful Termination`, Karpenter `Underutilized`); readiness/liveness failures; cold-start gap |
| Single customer service 504 | In-cluster health check first (`kubectl exec deploy/<svc> -- wget -qO- localhost:<port>/healthz`); if healthy in-cluster, the break is ALB → pod: `describe-target-health`, security groups, recent node recycle |
| Multiple customer services 504 | Bulk `describe-target-health` across all target groups; many `Target.Timeout` on the same ALB means a shared ALB/SG/node cause, not per-service bugs |
| Nodes NotReady | `kubectl get nodes`, `kubectl describe node/<node>`; kubelet / node-controller events; recent terraform apply or node recycle |
| Redis stream backlog | Search for a recent identical SEV first; if duplicate, cancel with a link. Otherwise investigate consumers and stream length |
| "Automatically resolved" | Investigate anyway: capture pod status and events before evidence ages out, find the trigger |

## Red flags

Patterns Richard calls out whenever they appear:

1. Exit 137 with reason `Error` instead of `OOMKilled` — kubelet killed the container after liveness probe failures. Look at probe timeouts, event-loop stalls, graceful-shutdown hangs.
2. In-cluster health passes but the public endpoint fails — the break is ALB → pod (security group, target group, node recycle), not the app.
3. HPA stuck at max with low actual load — request vs. limit misconfiguration; the target is a percentage of *request*.
4. Correlated failure across all replicas at once — Karpenter/eviction removed every target; propose a PDB and readiness tuning.
5. Spot capacity or Spot interruptions delaying recovery for a service where outage means data loss.
6. A comparable alert missing on another platform (e.g. ECS autoscaling max vs. k8s HPA max alert).
7. Unbounded accumulation in a single trigger execution (hundreds of provider calls at `currentPage=0`) — OOM risk.
8. Security-group drift after a node recycle — check `alb.ingress.kubernetes.io/manage-backend-security-group-rules` and `aws-load-balancer-controller` health/requests.
