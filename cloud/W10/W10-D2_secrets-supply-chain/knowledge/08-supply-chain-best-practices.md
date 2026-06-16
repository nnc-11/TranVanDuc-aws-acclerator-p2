# Supply Chain Security Best Practices

## End-to-End Supply Chain Model

```
Developer Code Commit
    ↓
Git Repository (GitHub, GitLab)
    ├─ Security scanning (SAST, secret scanning)
    ├─ Branch protection rules
    └─ Approval workflows
    ↓
CI/CD Pipeline (GitHub Actions, GitLab CI)
    ├─ Unit tests
    ├─ Security scanning (dependencies, container)
    ├─ Build artifact (container image)
    ├─ Scan with Trivy
    ├─ Generate SBOM (cyclonedx, spdx)
    ├─ Sign with Cosign
    └─ Push to registry
    ↓
Container Registry (ECR, GCR, etc)
    ├─ Image storage
    ├─ Signature storage (OCI referrers)
    ├─ SBOM storage (attestation)
    ├─ Registry access control (IAM)
    ├─ Registry scanning (continuous)
    └─ Image retention policy
    ↓
Kubernetes Deployment
    ├─ Admission controller
    ├─ Verify signature
    ├─ Check SBOM
    ├─ CVE exception lookup
    ├─ Image pull secrets
    └─ Pod security context
    ↓
Runtime Pod
    ├─ Network policies
    ├─ Resource limits
    ├─ Secret rotation (ESO)
    ├─ Audit logging
    └─ Runtime monitoring
```

## Security Checklist

### Source Code Level

- [ ] **Secret Scanning**
  ```bash
  # Pre-commit hook
  git-secret add secret.json
  git-secret hide
  ```

- [ ] **SAST (Static Application Security Testing)**
  ```yaml
  # CI pipeline
  - uses: github/super-linter@v4
    with:
      DEFAULT_BRANCH: main
  ```

- [ ] **Dependency Scanning**
  ```bash
  # Check dependencies
  npm audit
  pip install safety
  ```

- [ ] **Code Review Requirements**
  ```yaml
  # GitHub branch protection
  require_code_review: 2
  require_security_approval: 1
  ```

### Build Pipeline Level

- [ ] **Container Image Scanning**
  ```yaml
  - name: Trivy scan
    run: trivy image --exit-code 1 --severity CRITICAL image:tag
  ```

- [ ] **Image Signing**
  ```yaml
  - name: Cosign sign
    run: cosign sign --key cosign.key image:tag
  ```

- [ ] **SBOM Generation**
  ```yaml
  - name: Generate SBOM
    run: syft image:tag -o json > sbom.json
  ```

- [ ] **Build Provenance (SLSA)**
  ```yaml
  - uses: slsa-framework/slsa-github-generator/.github/workflows/builder@v1.9.0
    with:
      builder-image: ubuntu-latest
  ```

### Registry Level

- [ ] **Image Immutability**
  ```bash
  # ECR
  aws ecr put-image-tag-mutability \
    --repository-name myapp \
    --image-tag-mutability IMMUTABLE
  ```

- [ ] **Image Signing Verification**
  ```bash
  cosign verify --key cosign.pub image:tag
  ```

- [ ] **Image Vulnerability Scanning**
  ```bash
  # ECR continuous scanning
  aws ecr start-image-scan --repository-name myapp
  ```

- [ ] **Access Control (IAM)**
  ```json
  {
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "arn:aws:iam::ACCOUNT:role/EKS",
        "Action": "ecr:GetDownloadUrlForLayer"
      }
    ]
  }
  ```

### Kubernetes Deployment Level

- [ ] **Image Pull Secrets**
  ```yaml
  imagePullSecrets:
  - name: ecr-credentials
  ```

- [ ] **Signature Verification Webhook**
  ```yaml
  ValidatingWebhookConfiguration:
    - verify image signatures
    - reject unsigned images
  ```

- [ ] **Network Policies**
  ```yaml
  NetworkPolicy:
    ingress/egress rules
    pod-to-pod communication
  ```

- [ ] **Pod Security Standards**
  ```yaml
  securityContext:
    runAsNonRoot: true
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
  ```

### Runtime Level

- [ ] **Audit Logging**
  ```bash
  # K8s audit policy
  kind: Event
  verb: get,create,update,delete
  resources: pods,secrets
  ```

- [ ] **Secret Rotation**
  ```yaml
  ExternalSecret:
    refreshInterval: 60s
    # Secrets rotated without pod restart
  ```

- [ ] **Runtime Monitoring**
  ```bash
  # Falco rules for suspicious activity
  runtime_security monitoring
  ```

## Practical Implementation: Complete Pipeline

### 1. Repository Setup

```yaml
# .github/workflows/secure-build.yml
name: Secure Build & Deploy

on:
  push:
    branches: [main]
    paths:
      - 'src/**'
      - 'Dockerfile'

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}/myapp

jobs:
  security-checks:
    runs-on: ubuntu-latest
    steps:
      # Secret scanning
      - uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD
      
      # SAST
      - uses: github/super-linter@v4
        with:
          DEFAULT_BRANCH: main
      
      # Dependency check
      - uses: dependency-check/Dependency-Check_Action@main
        with:
          path: '.'
          format: 'JSON'

  build-and-sign:
    needs: security-checks
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
      packages: write
    steps:
      - uses: actions/checkout@v4

      # Build image
      - uses: docker/build-push-action@v5
        with:
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}

      # Scan with Trivy
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          format: 'json'
          output: 'trivy-results.json'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'

      # Generate SBOM
      - uses: anchore/sbom-action@v0
        with:
          image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          format: json
          output-file: sbom.json

      # Sign image with keyless OIDC
      - uses: sigstore/cosign-installer@v3
      - name: Sign & attest image
        env:
          COSIGN_EXPERIMENTAL: 1
        run: |
          # Combine attestations
          jq -s '{
            sbom: .[0],
            trivy: .[1],
            source: "github.com/${{ github.repository }}",
            commit: "${{ github.sha }}"
          }' sbom.json trivy-results.json > attestation.json
          
          # Sign
          cosign sign --yes \
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          
          # Attach attestation
          cosign attest --yes \
            --predicate attestation.json \
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}

  deploy:
    needs: build-and-sign
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Deploy to K8s cluster
      - name: Deploy
        run: |
          # kubectl applies pod - admission webhook verifies
          kubectl apply -f k8s/deployment.yaml
```

### 2. Kubernetes Deployment

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
        version: v1
      annotations:
        # Track supply chain provenance
        supply-chain.example.com/sbom: "ghcr.io/myapp:v1.0.sbom.json"
        supply-chain.example.com/signed-by: "github/cosign"
    spec:
      serviceAccountName: myapp
      
      # Security context
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 2000
      
      # Image pull secret for private registry
      imagePullSecrets:
      - name: ghcr-secret
      
      containers:
      - name: app
        image: ghcr.io/myapp:sha256:abc123def456
        imagePullPolicy: Always
        
        # Security context for container
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
        
        # Resource limits
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        
        # Secrets via ESO
        volumeMounts:
        - name: secrets
          mountPath: /etc/secrets
          readOnly: true
        
        # Health checks
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
      
      # Secret from ESO
      volumes:
      - name: secrets
        secret:
          secretName: myapp-secrets  # Managed by ExternalSecret

---
# Network policies
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: myapp-netpol
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
  - to:
    - podSelector:
        matchLabels:
          app: database

---
# ExternalSecret for secret rotation
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: myapp-secrets
spec:
  refreshInterval: 60s
  secretStoreRef:
    name: aws-secrets
  target:
    name: myapp-secrets
  data:
  - secretKey: database_url
    remoteRef:
      key: k8s/myapp/database-url
  - secretKey: api_key
    remoteRef:
      key: k8s/myapp/api-key
```

### 3. Admission Controller Config

```yaml
# admission-config.yaml
---
# Verify image signatures
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: image-signature-verification
spec:
  admissionReviewVersions: ["v1"]
  clientConfig:
    service:
      name: cosign-webhook
      namespace: kube-system
      path: "/verify"
    caBundle: LS0tLS1CRUdJTi...
  
  rules:
  - operations: ["CREATE"]
    resources: ["pods"]
    failurePolicy: Fail
    namespaceSelector:
      matchLabels:
        enforce-signed-images: "true"

---
# Pod Security Standards
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: pod-security
spec:
  failurePolicy: fail
  validationActions: [deny]
  matchResources:
    resourceRules:
    - apiGroups: [""]
      resources: ["pods"]
  auditAnnotations:
  - key: security-context
    valueExpression: object.spec.securityContext
  rules:
  - expression: >
      object.spec.containers.all(c,
        !c.securityContext.privileged &&
        c.securityContext.runAsNonRoot == true
      )
    message: "Must run non-root"
```

## Monitoring & Compliance

### Metrics to Track

```prometheus
# Image signatures verified
image_signature_verifications_total{status="success|failure"}

# CVE exceptions expiring
cve_exceptions_expiring_soon{namespace, expires_in_days}

# Secret rotations
secret_rotations_total{status="success|failure"}

# Deployment audit events
pod_creation_audit_events_total{reason="approved|rejected|blocked"}
```

### Compliance Reports

```bash
#!/bin/bash
# Weekly supply chain compliance report

echo "=== Supply Chain Security Report ==="
echo "Week of $(date -d 'last monday' +%Y-%m-%d)"

echo ""
echo "=== Image Signatures ==="
kubectl get pods -A \
  -o jsonpath='{.items[*].spec.containers[*].image}' | \
  xargs -I {} sh -c 'cosign verify {} 2>/dev/null && echo "✓ {}" || echo "✗ {}"'

echo ""
echo "=== Active CVE Exceptions ==="
kubectl get configmap cve-exceptions -n kube-system -o yaml | \
  yq '.data.exceptions | fromjson[] | select(.expires > now) | .cve'

echo ""
echo "=== Secrets Rotated ==="
kubectl logs -n external-secrets -l app=external-secrets | grep rotation | wc -l

echo ""
echo "=== Admission Webhook Events ==="
kubectl get events -A --field-selector reason=Denied | wc -l
```

## Troubleshooting Supply Chain Issues

| Issue | Diagnosis | Fix |
|-------|-----------|-----|
| Signature verification fails | Image not signed, or key mismatch | Rebuild & sign image, update public key |
| Image scanning times out | Large image, slow registry | Increase timeout, cache scan results |
| Secret rotation fails | ESO not running, AWS permissions | Check ESO logs, verify IAM role |
| Pod deployment rejected | Unsigned image, CVE not approved | Sign image or add CVE exception |

## References & Further Reading

1. **SLSA Framework**: Supply-chain Levels for Software Artifacts
   - https://slsa.dev/

2. **Sigstore**: Open source security infrastructure
   - https://www.sigstore.dev/

3. **CISA**: Software Supply Chain Security
   - https://www.cisa.gov/secure-software-development-framework

4. **NIST**: Secure Software Development Framework
   - https://csrc.nist.gov/projects/ssdf

---

**Complete**: W10-D2 Learning Path Finished
