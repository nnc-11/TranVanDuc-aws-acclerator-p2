# ResourceQuota & LimitRange - Resource Governance

## Overview

Resource governance in Kubernetes ensures fair resource allocation and prevents resource starvation through:
- **ResourceQuota**: Aggregate resource limits per namespace
- **LimitRange**: Per-pod and per-container resource constraints

## ResourceQuota

### Purpose
- Limit total CPU/memory per namespace
- Prevent one team from consuming all cluster resources
- Enforce organizational resource policies
- Track usage across namespaces

### Key Concepts

| Field | Purpose |
|-------|---------|
| `requests.cpu` | Reserved compute capacity |
| `requests.memory` | Reserved memory capacity |
| `limits.cpu` | Maximum CPU available |
| `limits.memory` | Maximum memory available |
| `pods` | Max pod count |
| `services.loadbalancers` | Max LB services |
| `persistentvolumeclaims` | Max PVC count |

### Example

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: production
spec:
  hard:
    requests.cpu: "100"
    requests.memory: "200Gi"
    limits.cpu: "200"
    limits.memory: "400Gi"
    pods: "100"
    services.loadbalancers: "2"
    persistentvolumeclaims: "10"
  scopeSelector:
    matchExpressions:
    - operator: In
      scopeName: PriorityClass
      values: ["high", "medium"]
```

### Quota Scopes

```yaml
scopeSelector:
  matchExpressions:
  - operator: In
    scopeName: PriorityClass
    values: ["high"]
  - operator: NotIn
    scopeName: BestEffort
    values: ["true"]
```

Available scopes:
- `BestEffort` / `NotBestEffort` - QoS class
- `PriorityClass` - Priority level
- `Terminating` / `NotTerminating` - Pod lifecycle

### Viewing Quota Usage

```bash
# List all quotas in namespace
kubectl get resourcequota -n production

# View detailed quota info
kubectl describe resourcequota compute-quota -n production

# Check used vs available
kubectl describe ns production | grep -A5 "Resource Quotas"
```

## LimitRange

### Purpose
- Set min/max resource requests per pod/container
- Prevent pods with insufficient or excessive resources
- Provide default requests/limits if not specified
- Ensure realistic resource configurations

### Types of Limits

| Type | Applies To |
|------|-----------|
| `Pod` | Per pod (sum of all containers) |
| `Container` | Per individual container |
| `PersistentVolumeClaim` | Per PVC |

### Example

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: compute-limit
  namespace: production
spec:
  limits:
  # Container limits
  - type: Container
    min:
      cpu: "10m"
      memory: "32Mi"
    max:
      cpu: "4"
      memory: "8Gi"
    default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "250m"
      memory: "256Mi"
  
  # Pod limits (sum of containers)
  - type: Pod
    min:
      cpu: "10m"
      memory: "32Mi"
    max:
      cpu: "8"
      memory: "16Gi"
  
  # PVC limits
  - type: PersistentVolumeClaim
    min:
      storage: "1Gi"
    max:
      storage: "100Gi"
```

### Fields Explained

```yaml
min:        # Minimum value pod/container must request
max:        # Maximum value pod/container can request
default:    # Default limit if not specified
defaultRequest: # Default request if not specified
```

### Request vs Limit

```yaml
resources:
  requests:  # Reserved for pod (minimum guarantee)
    cpu: "250m"
    memory: "256Mi"
  limits:    # Maximum pod can use
    cpu: "500m"
    memory: "512Mi"
```

## D3 Resource Governance Strategy

### Namespace Structure

```yaml
# Developer namespace - higher limits, burstable
apiVersion: v1
kind: Namespace
metadata:
  name: development
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    requests.cpu: "50"
    requests.memory: "100Gi"
    limits.cpu: "100"
    limits.memory: "200Gi"
    pods: "200"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-limit
  namespace: development
spec:
  limits:
  - type: Container
    min:
      cpu: "5m"
      memory: "16Mi"
    max:
      cpu: "2"
      memory: "4Gi"
    default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"

# Production namespace - strict, guaranteed
---
apiVersion: v1
kind: Namespace
metadata:
  name: production
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-quota
  namespace: production
spec:
  hard:
    requests.cpu: "200"
    requests.memory: "400Gi"
    limits.cpu: "300"
    limits.memory: "600Gi"
    pods: "150"
---
apiVersion: v1
kind: LimitRange
metadata:
  name: prod-limit
  namespace: production
spec:
  limits:
  - type: Container
    min:
      cpu: "100m"
      memory: "128Mi"
    max:
      cpu: "4"
      memory: "8Gi"
    default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "250m"
      memory: "256Mi"
```

## Best Practices

### ResourceQuota

1. **Start Conservative**: Begin with lower limits, increase as needed
2. **Monitor Usage**: Track quota consumption via metrics
3. **Tier by Priority**: Different quotas for different QoS classes
4. **Team Allocation**: One quota per team/department
5. **Document Rationale**: Why specific limits?

### LimitRange

1. **Set Both Request & Limit**: Prevents surprises
2. **Realistic Minimums**: Ensure pods can actually run
3. **Reasonable Maximums**: Prevent runaway resources
4. **Use Defaults**: Don't require manual specification
5. **Per-Namespace**: Tailor to workload type

### Monitoring

```bash
# Check quota status
kubectl top nodes
kubectl top pods -n production

# Alert on quota exhaustion
kubectl api-resources | grep resourcequota

# Export quota metrics
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes | jq .
```

## Troubleshooting

### Pod Rejected: "exceeds quota"
```bash
# Check quota
kubectl describe resourcequota -n <ns>

# Identify heavy pods
kubectl top pods -n <ns> --sort-by=memory
```

### Pod Rejected: "violates minimum"
```bash
# Check LimitRange
kubectl describe limitrange -n <ns>

# Fix: increase pod resources
```

## Integration with W10

- **W8 Foundation**: Cluster capacity planning
- **W9 Observability**: Track quota usage metrics
- **W10 Platform**: Enforce governance policies
- **Role-based Quotas**: Developer < SRE < Platform team

## Next Steps

→ Move to chaos testing validation
→ Integrate with cost anomaly detection
→ Create runbooks for quota violations
