# CVE Exception Policies - Managing Known Vulnerabilities

## Overview
CVE (Common Vulnerabilities and Exposures) exception policies cho phép whitelist những known vulnerabilities với lý do được approved - không phải block toàn bộ image vì một CVE nhỏ.

**Use cases**:
- CVE chỉ ảnh hưởng khi code path không dùng
- Fix available nhưng cần planned maintenance window
- Vendor patch in progress
- False positive từ scanner
- Acceptable risk sau security review

## CVE Exception Models

### Model 1: Image-level Exception

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
  annotations:
    # Approved CVEs for this specific image
    images/cve-exceptions: "gcr.io/my-project/app:v1.0=CVE-2021-1234,CVE-2022-5678"
    # Expiry date (ISO format)
    images/exception-expiry: "2024-12-31"
    # Reason for exception
    images/exception-reason: "CVE only affects Windows, we use Linux"
    # Approved by
    images/exception-approved-by: "security-team@company.com"
spec:
  containers:
  - name: app
    image: gcr.io/my-project/app:v1.0
```

### Model 2: Namespace-level Exception Policy

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: legacy-apps
  annotations:
    # All pods in this namespace allow these CVEs
    cve-exceptions: "CVE-2020-1111,CVE-2021-2222"
    exception-expiry: "2024-06-30"
    exception-reason: "Legacy app, scheduled for retirement June 2024"
    exception-approved-by: "platform-team"
```

### Model 3: ConfigMap-based Exception Registry

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cve-exceptions
  namespace: kube-system
data:
  exceptions.json: |
    [
      {
        "cve": "CVE-2021-1234",
        "affected_packages": ["openssl"],
        "reason": "Only affects TLS 1.0 which we disabled",
        "approved_by": "security-review-2024-01-15",
        "expires": "2024-12-31",
        "mitigations": [
          "TLS 1.0 disabled globally",
          "WAF blocks older clients"
        ]
      },
      {
        "cve": "CVE-2022-5678",
        "affected_packages": ["curl"],
        "reason": "Server-side only, not exploitable from our infra",
        "approved_by": "ciso-approval",
        "expires": "2025-06-30"
      }
    ]
```

## Admission Controller Implementation

### Validating Webhook with CVE Exceptions

```python
from kubernetes import client, config
from datetime import datetime
import json
import subprocess

class CVEExceptionValidator:
    def __init__(self):
        self.exceptions = self.load_exceptions()
    
    def load_exceptions(self):
        """Load CVE exceptions from ConfigMap"""
        v1 = client.CoreV1Api()
        try:
            cm = v1.read_namespaced_config_map(
                "cve-exceptions", 
                "kube-system"
            )
            return json.loads(cm.data.get('exceptions.json', '[]'))
        except:
            return []
    
    def validate_pod(self, pod_name, namespace, containers):
        """Validate pod's container images against CVE exceptions"""
        for container in containers:
            image = container['image']
            
            # Get pod annotations
            annotations = pod.metadata.annotations or {}
            
            # Scan image for CVEs
            cves = self.scan_image(image)
            
            # Check CVEs against exceptions
            approved_cves = self.get_approved_cves(
                image, 
                namespace,
                annotations
            )
            
            # Verify all CVEs are approved
            unapproved = [cve for cve in cves if cve not in approved_cves]
            if unapproved:
                return {
                    'allowed': False,
                    'reason': f'Unapproved CVEs: {", ".join(unapproved)}'
                }
        
        return {'allowed': True}
    
    def scan_image(self, image):
        """Scan image with Trivy, return CVE list"""
        try:
            result = subprocess.run(
                ['trivy', 'image', '--format', 'json', image],
                capture_output=True,
                timeout=60
            )
            data = json.loads(result.stdout)
            cves = set()
            for result in data.get('Results', []):
                for vuln in result.get('Vulnerabilities', []):
                    cves.add(vuln['VulnerabilityID'])
            return list(cves)
        except Exception as e:
            # If scan fails, reject (fail-safe)
            return ['SCAN_FAILED']
    
    def get_approved_cves(self, image, namespace, annotations):
        """Get approved CVE list for image"""
        approved = set()
        
        # Check image-level exceptions
        image_exceptions = annotations.get('images/cve-exceptions', '')
        if image_exceptions:
            for item in image_exceptions.split(','):
                if f"{image}=" in item:
                    cves = item.split('=')[1].split(',')
                    approved.update(cves)
        
        # Check namespace-level exceptions
        ns_exceptions = annotations.get('cve-exceptions', '')
        if ns_exceptions:
            approved.update(ns_exceptions.split(','))
        
        # Check global ConfigMap exceptions
        for exc in self.exceptions:
            if not self.is_exception_valid(exc):
                continue
            approved.add(exc['cve'])
        
        return approved
    
    def is_exception_valid(self, exception):
        """Check if exception is still valid (not expired)"""
        expiry_str = exception.get('expires')
        if not expiry_str:
            return True
        
        expiry = datetime.fromisoformat(expiry_str)
        return datetime.now() < expiry
```

### Webhook Configuration

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: cve-exception-validator
spec:
  admissionReviewVersions: ["v1"]
  clientConfig:
    service:
      name: cve-validator
      namespace: kube-system
      path: "/validate-cve"
    caBundle: ...
  
  rules:
  - operations: ["CREATE"]
    resources: ["pods"]
    failurePolicy: Fail
    sideEffects: None
    timeoutSeconds: 60
  
  namespaceSelector:
    matchLabels:
      enforce-cve-policy: "true"
```

## Using Kyverno for CVE Exception Management

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: reject-images-with-cves
spec:
  validationFailureAction: enforce
  rules:
  - name: reject-high-cves
    match:
      resources:
        kinds:
        - Pod
        namespaceSelector:
          matchLabels:
            enforce-cve-policy: "true"
    
    validate:
      message: "Image contains unapproved critical CVEs"
      pattern:
        spec:
          containers:
          - image: "?*"
            # Custom validation - compare against exception list
            # If CVEs found AND not in exception list -> DENY
```

Kyverno with custom image-verify:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: scan-and-verify-images
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: verify-image-with-exceptions
    match:
      resources:
        kinds:
        - Pod
    context:
    - name: cveExceptions
      configMap:
        name: cve-exceptions
        namespace: kube-system
    
    validate:
      message: "Image contains unapproved CVEs"
      # Custom logic via CEL (Common Expression Language)
      cel:
        expressions:
        - expression: >
            # Parse image digest
            # Scan for CVEs
            # Check against exceptions ConfigMap
            # Allow only if all CVEs in exception list
            image_cves.all(cve, 
              cve in cveExceptions.cve_list && 
              cveExceptions[cve].expires > now
            )
```

## Exception Approval Workflow

### 1. Request Exception

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
  annotations:
    # Request exception - not yet approved
    images/cve-exception-request: "CVE-2024-1111"
    images/exception-request-reason: "Upgrading database in next sprint"
    images/exception-requested-by: "app-team@company.com"
spec:
  containers:
  - name: app
    image: myapp:v1.0
```

### 2. Security Team Reviews & Approves

Script to process exceptions:

```python
def approve_cve_exception(cve, package, reason, approver, expires):
    """Add CVE to approved exceptions"""
    exception_entry = {
        "cve": cve,
        "affected_packages": [package],
        "reason": reason,
        "approved_by": approver,
        "approved_date": datetime.now().isoformat(),
        "expires": expires,
        "status": "approved"
    }
    
    # Add to ConfigMap
    add_to_exceptions_configmap(exception_entry)
    
    # Log to audit trail
    log_exception_approval(exception_entry)
    
    # Notify requestor
    notify_team(f"Exception {cve} approved until {expires}")
```

### 3. Monitor & Report

```bash
# Find expiring exceptions
kubectl get configmap cve-exceptions -n kube-system -o json | \
  jq '.data.exceptions | fromjson | map(select(.expires < now + 30days))'

# Pods using exceptions
kubectl get pods -A \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.images/cve-exceptions}{"\n"}{end}'

# Exception report
kubectl logs -n kube-system -l app=cve-validator | grep "exception"
```

## Best Practices

1. **Minimize Exception Use**
   ```
   Week 1: 0 exceptions (target)
   Week 2: Max 5 exceptions (threshold)
   Week 4: All exceptions reviewed
   Month 2+: Must justify any new exceptions
   ```

2. **Short Expiry Dates**
   ```
   Exception created: 2024-01-15
   Expiry: 30-60 days
   Force re-approval after expiry
   ```

3. **Document Thoroughly**
   ```yaml
   exception-reason: "EXPLICIT reason why safe"
   exception-approved-by: "approver email"
   exception-approved-date: "2024-01-15"
   exception-risk-assessment: "URL to risk doc"
   exception-mitigation: "What we do to reduce risk"
   ```

4. **Audit Trail**
   - Log all exception approvals
   - Track who approved
   - Monitor usage
   - Regular reporting

5. **Regular Review**
   ```bash
   # Monthly review script
   for exception in $(get_active_exceptions); do
     expires=$(get_expiry $exception)
     if days_until_expiry < 7; then
       alert_team "Exception expiring: $exception"
     fi
   done
   ```

## Hands-on Lab

```bash
# 1. Create exception ConfigMap
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: cve-exceptions
  namespace: kube-system
data:
  exceptions.json: |
    [
      {
        "cve": "CVE-2021-1234",
        "affected_packages": ["curl"],
        "reason": "Server-side only",
        "approved_by": "security-team",
        "expires": "2025-12-31"
      }
    ]
EOF

# 2. Deploy image with known CVE
kubectl run test --image=curlimages/curl:7.75.0
# Webhook intercepts - checks if CVE in exception list

# 3. Add pod annotation
kubectl annotate pod test \
  images/cve-exceptions="CVE-2021-1234" \
  --overwrite
# Now pod is allowed

# 4. Monitor exceptions
kubectl get configmap cve-exceptions -n kube-system -o yaml
```

---

**Next**: → 08-supply-chain-best-practices.md
