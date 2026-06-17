# Chaos Testing - Resilience Validation

## Overview

Chaos engineering validates system resilience under failure conditions.
- **Chaos Mesh**: Native Kubernetes chaos engine
- **Litmus**: Community chaos testing framework
- **Gremlin**: Commercial chaos platform
- Custom webhooks via admission controllers

## Goals

1. **Validate Recovery**: Can system recover from failures?
2. **Identify Weaknesses**: Where are single points of failure?
3. **Test Runbooks**: Do incident procedures work?
4. **Verify Observability**: Can we detect and alert on chaos?
5. **Build Confidence**: Production system is resilient

## Types of Chaos Tests

### 1. Pod-Level Chaos

**Pod Kill** - Terminate running pods
```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: kill-test-pod
  namespace: chaos-testing
spec:
  action: pod-kill
  mode: one
  selector:
    namespaces:
    - production
    labelSelectors:
      app: test-app
  scheduler:
    cron: "@every 5m"  # Run every 5 minutes
  duration: 5m
```

**Pod Delay** - Simulate slow responses
```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: inject-delay
spec:
  action: pod-failure
  mode: percentage
  duration: 10m
  scheduler:
    cron: "@every 10m"
```

### 2. Network Chaos

**Network Partition** - Simulate network split
```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: network-partition
spec:
  action: partition
  mode: one
  selector:
    namespaces:
    - production
  duration: 5m
  direction: to
  target:
    selector:
      namespaces:
      - production
      labelSelectors:
        tier: backend
```

**Packet Loss** - Drop packets
```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: packet-loss
spec:
  action: loss
  mode: percentage
  loss: "50"  # 50% packet loss
  selector:
    namespaces:
    - production
```

**Latency Injection** - Add network delay
```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: inject-latency
spec:
  action: delay
  mode: all
  delay:
    latency: "100ms"
    jitter: "10ms"
  selector:
    namespaces:
    - production
```

### 3. Resource Chaos

**CPU Stress** - Consume CPU
```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: StressChaos
metadata:
  name: cpu-stress
spec:
  action: stress
  mode: percentage
  stressors:
    cpu:
      workers: 4
      load: 80
  duration: 10m
  selector:
    namespaces:
    - production
    labelSelectors:
      workload: api
```

**Memory Pressure** - Consume memory
```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: StressChaos
metadata:
  name: memory-stress
spec:
  action: stress
  mode: percentage
  stressors:
    memory:
      workers: 1
      size: "256Mi"
  duration: 5m
  selector:
    namespaces:
    - production
```

### 4. Disk I/O Chaos

**I/O Delay** - Slow disk operations
```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: IOChaos
metadata:
  name: io-delay
spec:
  action: latency
  delay: 100ms
  percent: 50  # 50% of I/O affected
  selector:
    namespaces:
    - production
```

## D3 Chaos Testing Plan

### Test Scenarios

#### 1. Pod Termination Test
**Objective**: Verify pod restart and traffic rerouting

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: app-pod-kill
  namespace: chaos-testing
spec:
  action: pod-kill
  mode: percentage
  percentage: 30  # Kill 30% of pods
  selector:
    namespaces:
    - production
    labelSelectors:
      app: api-server
  duration: 2m
  scheduler:
    cron: "0 */2 * * *"  # Every 2 hours
```

**Validation Checklist**:
- [ ] Pods recover within SLA
- [ ] Alerts triggered in observability stack
- [ ] Traffic routed to surviving pods
- [ ] Request success rate > 99%

#### 2. Network Partition Test
**Objective**: Test distributed system consistency

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: db-partition
  namespace: chaos-testing
spec:
  action: partition
  mode: one
  selector:
    namespaces:
    - production
    labelSelectors:
      tier: database
  duration: 1m
  direction: to
  target:
    selector:
      namespaces:
      - production
      labelSelectors:
        tier: api
```

**Validation Checklist**:
- [ ] Write-ahead logging functional
- [ ] No data corruption
- [ ] Partition heals cleanly
- [ ] Runbook executed successfully

#### 3. Resource Exhaustion Test
**Objective**: Test resource limits and eviction

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: StressChaos
metadata:
  name: memory-exhaust
  namespace: chaos-testing
spec:
  action: stress
  mode: one
  stressors:
    memory:
      workers: 1
      size: "7Gi"  # Near node limit
  duration: 3m
  selector:
    namespaces:
    - production
```

**Validation Checklist**:
- [ ] Pod evicted gracefully
- [ ] LimitRange enforced
- [ ] ResourceQuota updated
- [ ] Events logged correctly

#### 4. Latency Test
**Objective**: Test application timeout handling

```yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: high-latency
  namespace: chaos-testing
spec:
  action: delay
  mode: all
  delay:
    latency: "1000ms"
    jitter: "100ms"
  selector:
    namespaces:
    - production
    labelSelectors:
      tier: api
  duration: 5m
```

**Validation Checklist**:
- [ ] Timeouts triggered appropriately
- [ ] Circuit breakers activated
- [ ] Fallback mechanisms work
- [ ] SLO maintained (if defined)

## Running Chaos Tests

### Setup Chaos Mesh

```bash
# Add Chaos Mesh repo
helm repo add chaos-mesh https://charts.chaos-mesh.org

# Install Chaos Mesh controller
helm install chaos-mesh chaos-mesh/chaos-mesh \
  --namespace=chaos-testing \
  --create-namespace \
  --set chaosDaemon.runtime=containerd \
  --set dashboard.securityMode=false

# Verify installation
kubectl get pods -n chaos-testing
```

### Execute Test

```bash
# Apply chaos scenario
kubectl apply -f chaos-pod-kill.yaml

# Monitor execution
kubectl describe podchaos app-pod-kill -n chaos-testing

# Watch pod behavior
kubectl get pods -n production -w

# Check events
kubectl get events -n production --sort-by='.lastTimestamp'

# Remove chaos
kubectl delete podchaos app-pod-kill -n chaos-testing
```

### Automation

```bash
#!/bin/bash
# chaos-runner.sh - Run series of chaos tests

TESTS=(
  "chaos-pod-kill.yaml"
  "chaos-network-partition.yaml"
  "chaos-latency.yaml"
)

for test in "${TESTS[@]}"; do
  echo "Running: $test"
  kubectl apply -f "$test"
  
  # Wait for stabilization
  sleep 5m
  
  # Check metrics
  kubectl top pods -n production
  
  # Cleanup
  kubectl delete -f "$test"
  sleep 2m
done
```

## Observability Integration (W9)

Monitor chaos tests with:

```yaml
# Prometheus alert for pod crash rate
groups:
- name: chaos_testing
  rules:
  - alert: HighPodCrashRate
    expr: rate(kube_pod_container_status_restarts_total[5m]) > 0.1
    for: 5m
    annotations:
      summary: "High pod crash rate detected"
      
  - alert: NetworkLatencyHigh
    expr: histogram_quantile(0.99, http_request_duration_seconds) > 1
    for: 2m
    annotations:
      summary: "Network latency exceeds SLA"
```

## Runbook Integration (Chaos → Runbook)

Chaos tests validate runbooks:

```yaml
# chaos-validates-runbook.yaml
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: test-runbook
  annotations:
    runbook: /runbooks/pod-crash-recovery.md
    escalation-policy: oncall-sre
spec:
  action: pod-kill
  mode: percentage
  percentage: 20
  selector:
    namespaces:
    - production
  duration: 5m
```

## Best Practices

1. **Start Small**: Single pod/node before cascading failures
2. **Have Escape Hatch**: Kill switch to stop chaos
3. **Monitor Continuously**: Real-time dashboards during tests
4. **Notify Team**: Don't run chaos silently
5. **Schedule Off-Peak**: Run during maintenance windows
6. **Document Results**: Create incident reports
7. **Improve Runbooks**: Update based on findings
8. **Automate Validation**: Metrics-driven test success/failure

## Integration Timeline

- **D3 Day**: Design chaos tests, validate recovery
- **D4-D5 Lab**: Automated chaos in cleanup scenarios
- **W11**: Continuous chaos monkey in production-like env
- **W12**: Cross-team chaos testing with full platform

## Next Steps

→ Create runbook templates from chaos findings
→ Integrate with observability stack
→ Plan incident response drills
