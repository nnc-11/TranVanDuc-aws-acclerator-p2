# Runbook Templates - Operational Playbooks

## Overview

Runbooks are step-by-step incident response procedures.
- **Automated**: Tested chaos scenarios become runbooks
- **Standardized**: Consistent format across team
- **Discoverable**: Easy to find during incidents
- **Validated**: Proven to work in chaos tests

## Runbook Template Structure

### Standard Format

```markdown
# Runbook: [Clear Title]

## Overview
- **Severity**: Critical/High/Medium/Low
- **Component**: What system/service
- **Duration**: Typical time to resolve
- **Authors**: Team responsible
- **Last Updated**: YYYY-MM-DD

## Alert
What metric/alert triggers this runbook?

## Impact
- What users/services affected?
- Business impact?
- Data at risk?

## Root Causes
Common causes for this issue

## Runbook

### Diagnosis
1. Confirm alert is real
2. Gather context/metrics
3. Determine scope

### Immediate Actions
1. Step 1: [Action]
2. Step 2: [Action]
... (numbered steps)

### Recovery
1. Step 1: [Command]
2. Step 2: [Command]
... (numbered steps)

### Verification
- [ ] Service responding
- [ ] Metrics normalized
- [ ] Users can access
- [ ] No error spikes

### Post-Incident
1. Document incident
2. Update metrics
3. Schedule retrospective

## Escalation
- Level 1: SRE on-call
- Level 2: Platform team lead
- Level 3: Incident commander

## Related Docs
- Links to other runbooks
- Architecture docs
- Troubleshooting guides

## See Also
- [Other related runbook]
- [Documentation link]
```

## D3 Runbook Library

### 1. Pod Crash Loop Recovery

```markdown
# Runbook: Pod Crash Loop Recovery

## Overview
- **Severity**: High
- **Component**: Kubernetes Pods
- **Duration**: 10-15 minutes
- **Team**: Platform SRE

## Alert
```
kube_pod_container_status_restarts_total rate > 0.5/min for 3m
```

## Impact
- Application service degradation
- Cascading failures if critical pod
- Potential data loss if persistent state

## Root Causes
- OOM killed (memory limit exceeded)
- Liveness probe failing
- Dependency unavailable
- Configuration error
- Insufficient CPU allocation

## Runbook

### Diagnosis
```bash
# 1. Get pod info
kubectl get pod -n NAMESPACE POD_NAME -o wide

# 2. Check status
kubectl describe pod -n NAMESPACE POD_NAME | grep -A5 "State\|Last State"

# 3. View logs
kubectl logs -n NAMESPACE POD_NAME --previous

# 4. Check events
kubectl get events -n NAMESPACE --field-selector involvedObject.name=POD_NAME

# 5. Check resource usage
kubectl top pod -n NAMESPACE POD_NAME
```

### Immediate Actions
1. **Verify**: Confirm it's actually crashing (not transient)
   ```bash
   kubectl get pod -n NAMESPACE POD_NAME --watch
   ```

2. **Gather Context**: Check recent changes
   ```bash
   kubectl rollout history deployment -n NAMESPACE
   kubectl describe deployment -n NAMESPACE
   ```

3. **Isolate**: Get pod logs for analysis
   ```bash
   kubectl logs -n NAMESPACE POD_NAME --all-containers --tail=100
   ```

### Recovery

#### If Memory-Related:
1. Check memory limit
   ```bash
   kubectl describe pod -n NAMESPACE POD_NAME | grep -A2 memory
   ```

2. Increase limit if appropriate
   ```bash
   kubectl set resources deployment -n NAMESPACE DEPLOY \
     --limits=memory=2Gi
   ```

3. Or scale horizontally (multiple pods)
   ```bash
   kubectl scale deployment -n NAMESPACE DEPLOY --replicas=3
   ```

#### If Dependency Issue:
1. Check dependency status
   ```bash
   kubectl get pods -n NAMESPACE -l tier=database
   kubectl get svc -n NAMESPACE
   ```

2. Verify connectivity
   ```bash
   kubectl run test-pod --image=busybox -- \
     sh -c "wget http://service-name.namespace.svc.cluster.local:port"
   ```

#### If Config Error:
1. Get configmap
   ```bash
   kubectl get configmap -n NAMESPACE CONFIG_NAME -o yaml
   ```

2. Edit and update
   ```bash
   kubectl edit configmap -n NAMESPACE CONFIG_NAME
   ```

3. Trigger pod restart
   ```bash
   kubectl rollout restart deployment -n NAMESPACE DEPLOY
   ```

#### If Code Issue:
1. Rollback to previous version
   ```bash
   kubectl rollout undo deployment -n NAMESPACE DEPLOY
   kubectl rollout status deployment -n NAMESPACE DEPLOY
   ```

### Verification
- [ ] Pod running (not restarting)
   ```bash
   kubectl get pod -n NAMESPACE POD_NAME
   ```

- [ ] Logs show healthy startup
   ```bash
   kubectl logs -n NAMESPACE POD_NAME --tail=20
   ```

- [ ] Metrics returned to normal
   ```bash
   kubectl top pod -n NAMESPACE POD_NAME
   ```

- [ ] Service available
   ```bash
   kubectl get svc -n NAMESPACE | grep SERVICE_NAME
   ```

### Post-Incident
1. Document in incident tracking system
2. Check if limit increase needed
3. Review logs for patterns
4. Schedule retrospective if frequent

## Escalation
- **Level 1 (15min)**: SRE on-call - execute diagnosis
- **Level 2 (30min)**: Platform team lead - resource limits review
- **Level 3 (45min)**: Incident commander - escalate if service down

## Related
- Runbook: OOM Killer Prevention
- Runbook: Dependency Failure Recovery
- Doc: Resource Limits Guide
```

### 2. Database Connection Pool Exhaustion

```markdown
# Runbook: Database Connection Pool Exhaustion

## Overview
- **Severity**: Critical
- **Component**: Database (ESO Secrets + App Connections)
- **Duration**: 5-10 minutes
- **Team**: Platform + App Team

## Alert
```
mysql_global_status_threads_connected / mysql_global_variables_max_connections > 0.8
```

## Impact
- New requests cannot reach database
- Complete service outage
- Cascading pod crashes

## Root Causes
- Connection leak in application
- Long-running query locks connection
- ESO secret rotation timeout
- Database restart required

## Runbook

### Diagnosis
```bash
# 1. Check active connections
kubectl exec -n NAMESPACE POD -- mysql -u USER -p -e \
  "SHOW PROCESSLIST;"

# 2. Check pool settings
kubectl exec -n NAMESPACE POD -- mysql -u USER -p -e \
  "SHOW VARIABLES LIKE 'max_connections';"

# 3. Check secret rotation status
kubectl get externalsecret -n NAMESPACE -o yaml

# 4. Check pod logs for connection errors
kubectl logs -n NAMESPACE POD --tail=50 | grep -i connection
```

### Immediate Actions
1. Kill idle connections
   ```bash
   kubectl exec -n NAMESPACE POD -- mysql -u USER -p -e \
     "KILL CONNECTION ID;"
   ```

2. Increase connection pool size temporarily
   ```bash
   kubectl set env deployment -n NAMESPACE APP \
     DB_POOL_SIZE=50
   kubectl rollout restart deployment -n NAMESPACE APP
   ```

### Recovery
1. Identify connection leak
2. Restart database if needed
3. Restart application pods

### Post-Incident
- [ ] Root cause identified
- [ ] Fix deployed
- [ ] Connection pool limits documented

## Related
- Runbook: Secret Rotation Failure
- Doc: ESO Configuration
```

### 3. High Network Latency

```markdown
# Runbook: High Network Latency

## Overview
- **Severity**: High
- **Component**: Kubernetes Network
- **Duration**: 10-20 minutes

## Alert
```
histogram_quantile(0.95, http_request_duration_seconds) > 2s
```

## Diagnosis
```bash
# 1. Check node CPU
kubectl top nodes

# 2. Check network plugin
kubectl get daemonset -n kube-system

# 3. Check CNI metrics
kubectl top pods -n kube-system

# 4. Test pod-to-pod latency
kubectl run test-client --image=nicolaka/netshoot -it -- bash
# Inside: ping service-name.namespace
```

### Recovery
1. Scale CNI resources if bottleneck
2. Check for noisy neighbors
3. Verify network MTU settings
4. Check DNS resolution performance

## Post-Incident
- Document latency baseline
- Add network latency alert
```

## Template Variations

### Quick Reference Card (1-pager)

```markdown
# [Service Name] - Quick Ref

| Aspect | Details |
|--------|---------|
| **Alert** | [metric > threshold] |
| **Root Cause** | [common causes] |
| **Quick Fix** | [fastest recovery step] |
| **Escalation** | [L1/L2/L3] |

**Diagnosis**:
```
[key commands]
```

**Recovery**:
```
[key commands]
```
```

### Automated Runbook (Python/Bash)

```bash
#!/bin/bash
# auto-runbook-pod-crash.sh
# Automated recovery for pod crash loop

NAMESPACE=${1:-default}
POD=${2:-}

if [ -z "$POD" ]; then
  echo "Usage: $0 NAMESPACE POD_NAME"
  exit 1
fi

echo "[INFO] Gathering diagnostics for $NAMESPACE/$POD"
kubectl describe pod -n "$NAMESPACE" "$POD" > pod-report.txt
kubectl logs -n "$NAMESPACE" "$POD" --previous > pod-logs.txt

echo "[INFO] Attempting automatic recovery..."

# Check if OOM
if grep -q "OOMKilled" pod-report.txt; then
  echo "[ACTION] Memory issue detected - increasing limit"
  DEPLOY=$(kubectl get pod -n "$NAMESPACE" "$POD" -o jsonpath='{.metadata.ownerReferences[0].name}')
  kubectl set resources deployment -n "$NAMESPACE" "$DEPLOY" \
    --limits=memory=2Gi
  kubectl rollout restart deployment -n "$NAMESPACE" "$DEPLOY"
fi

# Check if liveness probe failing
if grep -q "Liveness probe failed" pod-logs.txt; then
  echo "[ACTION] Liveness probe failing - restarting pod"
  kubectl delete pod -n "$NAMESPACE" "$POD"
fi

echo "[INFO] Waiting for recovery..."
kubectl wait --for=condition=ready pod -n "$NAMESPACE" "$POD" --timeout=60s
```

## Runbook Governance

### Review Checklist
- [ ] Clear, unambiguous steps
- [ ] Command syntax verified
- [ ] Tested in non-production
- [ ] Escalation criteria defined
- [ ] Time estimates realistic
- [ ] Related runbooks linked

### Maintenance
- Review quarterly
- Update after incidents
- Archive obsolete runbooks
- Version control all runbooks

## Integration with Platform (W10)

- **D1 RBAC**: Different runbooks per role
- **D2 Secrets**: Secret rotation runbooks
- **D3 Automation**: Runbook automation
- **D4-5 Lab**: Enforce runbook procedures
- **W11-12**: Cross-team runbook library

## Structure in Git

```
platform/
  runbooks/
    README.md
    database/
      connection-pool-exhaustion.md
      replication-lag.md
    kubernetes/
      pod-crash-loop.md
      network-latency.md
    observability/
      disk-space-low.md
      etcd-health.md
    templates/
      runbook-template.md
      decision-tree.md
```

## Next Steps

→ Create runbook from each chaos test
→ Automate runbook execution where possible
→ Train team on runbook procedures
→ Validate runbooks in W11-W12
