# Admission Webhook - Enforce Image Signing & Verify Signatures

## Overview
Admission webhooks là K8s feature cho phép intercept API requests trước khi objects được persist. Dùng để:
- Verify container image signatures (Cosign)
- Reject unsigned/unscanned images
- Enforce security policies
- Mutate objects (thêm labels, annotations)

## Architecture

```
┌──────────────────────────────────┐
│  kubectl apply (Pod)             │
└────────────────┬─────────────────┘
                 │
                 ▼
         ┌───────────────┐
         │ API Server    │
         └───────┬───────┘
                 │
                 ▼
    ┌────────────────────────────┐
    │ Admission Webhooks Chain   │
    ├────────────────────────────┤
    │ 1. ValidatingAdmissionPolicy│ ◄─ K8s 1.30+ native
    │ 2. ValidatingWebhook       │ ◄─ Custom validating
    │ 3. MutatingWebhook         │ ◄─ Custom mutating
    │ 4. Controllers             │ ◄─ Built-in (RBAC, etc)
    └────────────┬───────────────┘
                 │
        ┌────────┴────────┐
        │                 │
    ✓ ALLOW          ✗ REJECT
        │                 │
        ▼                 ▼
   Pod created         Error returned
```

## ValidatingAdmissionWebhook

### 1. Tạo Webhook Endpoint

```python
# webhook-server.py - FastAPI server
from fastapi import FastAPI, Request
import json
import base64
import subprocess

app = FastAPI()

@app.post("/validate")
async def validate_pod(request: Request):
    body = await request.json()
    
    # Extract pod from admission review
    pod = body['request']['object']
    pod_name = pod['metadata']['name']
    namespace = pod['metadata']['namespace']
    
    # Check each container image
    for container in pod['spec']['containers']:
        image = container['image']
        
        # Verify image signature
        result = verify_image_signature(image)
        
        if not result['signed']:
            # Reject unsigned images
            return {
                "apiVersion": "admission.k8s.io/v1",
                "kind": "AdmissionReview",
                "response": {
                    "uid": body['request']['uid'],
                    "allowed": False,
                    "status": {
                        "message": f"Image {image} is not signed"
                    }
                }
            }
    
    # Allow if all images signed
    return {
        "apiVersion": "admission.k8s.io/v1",
        "kind": "AdmissionReview",
        "response": {
            "uid": body['request']['uid'],
            "allowed": True
        }
    }

def verify_image_signature(image):
    # Call cosign to verify
    try:
        result = subprocess.run(
            ['cosign', 'verify', '--insecure-ignore-tlog=true', image],
            capture_output=True,
            timeout=10
        )
        return {'signed': result.returncode == 0}
    except Exception as e:
        return {'signed': False, 'error': str(e)}
```

### 2. Deploy Webhook Server

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: webhooks
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: image-signature-webhook
  namespace: webhooks
spec:
  replicas: 2
  selector:
    matchLabels:
      app: signature-webhook
  template:
    metadata:
      labels:
        app: signature-webhook
    spec:
      containers:
      - name: webhook
        image: signature-webhook:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8000
        env:
        - name: LOG_LEVEL
          value: "INFO"
        resources:
          limits:
            cpu: 500m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: image-signature-webhook
  namespace: webhooks
spec:
  ports:
  - port: 443
    targetPort: 8000
  selector:
    app: signature-webhook
```

### 3. Register ValidatingAdmissionWebhook

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: image-signature-verification
spec:
  admissionReviewVersions: ["v1"]
  clientConfig:
    service:
      name: image-signature-webhook
      namespace: webhooks
      path: "/validate"
    caBundle: LS0tLS1CRUdJTi... # base64 CA cert
  
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
    scope: "Namespaced"
    namespaceSelector:
      matchLabels:
        enforce-image-signature: "true"
  
  failurePolicy: Fail  # Reject if webhook unavailable
  sideEffects: None
  timeoutSeconds: 10
  namespaceSelector:
    matchLabels:
      enforce-image-signature: "true"
```

### 4. Enable on Namespace

```bash
# Label namespace to enforce
kubectl label namespace default enforce-image-signature=true

# Test: Try to deploy unsigned image
kubectl run test --image=nginx:latest -n default
# Error: Image nginx:latest is not signed ✗
```

## Using Kyverno for Policy-based Validation

Kyverno is alternative to webhooks, more declarative:

### 1. Install Kyverno
```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno \
  --namespace kyverno \
  --create-namespace \
  --set validationFailureAction=enforce
```

### 2. Require Image Signature (Kyverno Policy)

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-image-signature
spec:
  validationFailureAction: enforce
  rules:
  - name: verify-signature
    match:
      resources:
        kinds:
        - Pod
    verifyImages:
    - imageReferences:
      - "gcr.io/my-project/*"
      attestors:
      - entries:
        - keys:
            publicKeys: |
              -----BEGIN PUBLIC KEY-----
              MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE...
              -----END PUBLIC KEY-----
            signatureAlgorithm: sha256
      failureAction: fail
```

### 3. Test Policy

```bash
# Try unsigned image
kubectl run test --image=gcr.io/my-project/app:latest
# Error: Kyverno verification failed ✗

# Use signed image
kubectl run test --image=gcr.io/my-project/app:signed
# Success ✓
```

## Complete Example: Cosign + Admission Webhook

### Step 1: Build + Sign Image (CI)

```yaml
# GitHub Actions
- name: Build & Sign
  run: |
    docker build -t $REGISTRY/app:$SHA .
    docker push $REGISTRY/app:$SHA
    cosign sign --key cosign.key $REGISTRY/app:$SHA
```

### Step 2: Verify in Admission Controller

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: cosign-verification
spec:
  admissionReviewVersions: ["v1"]
  clientConfig:
    service:
      name: cosign-webhook
      namespace: kube-system
      path: "/verify"
    caBundle: ...
  
  rules:
  - operations: ["CREATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  
  failurePolicy: Fail
  timeoutSeconds: 30
```

### Step 3: Deploy Pod (End-to-End)

```bash
# Webhook automatically:
# 1. Extract image digest from spec
# 2. Search for signature in registry
# 3. Verify signature with public key
# 4. Allow/Reject pod creation

kubectl apply -f pod.yaml
# Webhook verifies: myapp:sha256:abc123 has valid signature ✓
# Pod created successfully
```

## Exception Handling - CVE Exceptions

Allow certain CVEs per image:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: cve-exception-policy
spec:
  rules:
  - name: check-cve-exceptions
    operations: ["CREATE"]
    resources: ["pods"]
    
    # Custom logic in webhook:
    # 1. Get image annotations
    # 2. Check against approved CVE list
    # 3. Scan image for CVEs
    # 4. Allow if CVEs in approved list
    # 5. Reject if unapproved CVE found
```

Exception annotation on image:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
  annotations:
    # Approved CVEs for this deployment
    cve-exceptions: "CVE-2021-1234,CVE-2022-5678"
    cve-exception-expiry: "2024-12-31"
spec:
  containers:
  - name: app
    image: myapp:v1.0
```

Webhook logic:

```python
def check_cve_exceptions(pod, approved_cves, scan_results):
    """
    Check if image CVEs are in approved list
    """
    pod_exceptions = pod.metadata.annotations.get('cve-exceptions', '').split(',')
    exception_expiry = pod.metadata.annotations.get('cve-exception-expiry')
    
    # Check if exception expired
    if datetime.fromisoformat(exception_expiry) < datetime.now():
        return {'allowed': False, 'reason': 'Exception expired'}
    
    # Get CVEs found in image scan
    image_cves = scan_results['vulnerabilities'].keys()
    
    # Check each CVE
    for cve in image_cves:
        if cve not in pod_exceptions:
            return {
                'allowed': False,
                'reason': f'Unapproved CVE found: {cve}'
            }
    
    return {'allowed': True}
```

## Monitoring & Audit

### View Webhook Activity

```bash
# Check webhook logs
kubectl logs -n webhooks -l app=signature-webhook

# Audit events
kubectl get events -n default

# Kyverno policy reports
kubectl get policyreport -A
kubectl get policyreport default-policy-report -o yaml
```

### Metrics

```yaml
# Prometheus metrics from webhook
webhook_admission_requests_total{
  webhook="image-signature-verification",
  decision="allow|deny",
  reason="reason"
}

# Example queries
# Rejection rate
rate(webhook_admission_requests_total{decision="deny"}[5m])

# By reason
sum(webhook_admission_requests_total) by (reason)
```

## Troubleshooting

| Issue | Debug |
|-------|-------|
| Webhook not called | Check `ValidatingWebhookConfiguration` selector matches namespace/resource |
| Always rejecting | Verify public key in webhook matches signing key |
| Webhook timeout | Check service endpoint, network policies |
| Can't verify signature | Ensure image digest not tag (tag is mutable) |

## Best Practices

1. **Use Namespace Labels for Enforcement**
   ```bash
   kubectl label namespace prod enforce-image-signature=true
   kubectl label namespace dev enforce-image-signature=false
   ```

2. **Gradual Rollout**
   - Week 1: Log-only (`auditAnnotations`)
   - Week 2: Warn (`failurePolicy: Ignore`)
   - Week 3+: Enforce (`failurePolicy: Fail`)

3. **High Availability**
   ```yaml
   failurePolicy: Fail  # Fail closed (safe default)
   replicas: 3          # Multiple webhook replicas
   timeoutSeconds: 5    # Quick timeout
   ```

4. **Exception Management**
   - Document CVE exceptions
   - Set expiry dates
   - Regular review + cleanup

5. **Performance**
   - Cache signature verification
   - Parallel validation
   - Monitor webhook latency

---

**Next**: → 07-exception-policy-cve.md
