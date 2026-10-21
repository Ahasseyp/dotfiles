# Commands

Snippets Richard uses, grouped by platform. Set `AWS_PROFILE` before `aws` commands, and use the right namespace for `kubectl` (Sentry lives in `-n sentry` on the observability cluster).

## kubectl-status.sh

```bash
./kubectl-status.sh <customer> <service>
```

Post the resulting markdown file in the dev investigation thread. Script: https://github.com/useparagon-internal/dev-utils/blob/main/support/kubectl-status.sh

## Kubernetes (customer installations, namespace `paragon`)

```bash
kubectl -n paragon get pods -o wide
kubectl -n paragon top pods
kubectl -n paragon get hpa
kubectl -n paragon get events
kubectl -n paragon get nodes
kubectl describe node/<node-name>

# In-cluster health check — bypasses the ALB to isolate where the path breaks
kubectl -n paragon exec deploy/<service> -- wget -qO- localhost:<port>/healthz

kubectl -n paragon get svc,endpoints <service>

# Temporary mitigation — persist in Git/Confluence afterwards
kubectl -n paragon patch deploy <service> --type json -p='[
  {"op": "replace", "path": "/spec/template/spec/containers/0/resources/limits/memory", "value":"800Mi"},
  {"op": "replace", "path": "/spec/template/spec/containers/0/resources/requests/memory", "value":"800Mi"}
]'
kubectl -n paragon rollout restart deploy/<service>
kubectl -n paragon rollout restart deploy/ingress-aws-load-balancer-controller
```

## Sentry observability cluster

```bash
export AWS_PROFILE=<observability-profile>
kubectl -n sentry get pods -l role=web -o wide
kubectl -n sentry get events
kubectl -n sentry logs <pod> --since=45m
```

Runbooks: [Sentry On-Call Runbook](https://app.notion.com/p/useparagon/Sentry-ON-CALL-RUNBOOK-3aa61d1eb9a8809c8d5fe9d1f7f1a910) · [BetterStack Health Check Monitors](https://app.notion.com/p/useparagon/BetterStack-Health-Check-Monitors-3c061d1eb9a88109b654df49faaf82e6)

## ECS (Cloud Production)

```bash
aws ecs describe-services \
  --cluster paragon-env-production-cluster \
  --services arn:aws:ecs:us-east-1:571812824132:service/paragon-env-production-cluster/<service> \
  --include TAGS
```

Check stopped tasks, exit codes/reasons, Spot weighting, autoscaling.

## ALB / target groups

```bash
LB_ARN=$(aws elbv2 describe-load-balancers --region <region> \
  --names <alb-name> \
  --query 'LoadBalancers[0].LoadBalancerArn' --output text)

aws elbv2 describe-target-groups --region <region> --load-balancer-arn "$LB_ARN" \
  --query "TargetGroups[?contains(TargetGroupName,'<service>')].[TargetGroupName,TargetGroupArn]" \
  --output table

aws elbv2 describe-target-health --region <region> --target-group-arn <tg-arn>

# Bulk scan across an entire installation
aws elbv2 describe-target-groups \
  --query 'TargetGroups[*].[TargetGroupName,TargetGroupArn]' \
  --output text | while read name arn; do
    echo "=== $name ==="
    aws elbv2 describe-target-health \
      --target-group-arn "$arn" \
      --query 'TargetHealthDescriptions[*].[Target.Id,Target.Port,TargetHealth.State,TargetHealth.Reason,TargetHealth.Description]' \
      --output table
  done
```

## External checks

```bash
http GET https://<service>.useparagon.com/healthz
traceroute <public-ip>
```

## BetterStack incident review

Pull from the incident page: monitor URL, start/resolved/acknowledged times, response code, request duration, resolved IP, response headers (`server: awselb/2.0` means the failure came from the ALB), body trace, and the similar-incidents page for scope.
