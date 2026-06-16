# Trivy - Container Image Vulnerability Scanning

## Overview
Trivy là open-source vulnerability scanner cho container images, filesystem, git repositories với:
- Fast scanning (seconds, not minutes)
- Multiple vulnerability databases
- Support OS packages + application dependencies
- JSON/SARIF report output
- CI/CD integration

## Installation

### Local Installation
```bash
# macOS
brew install aquasecurity/trivy/trivy

# Ubuntu/Debian
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
apt-get update && apt-get install trivy

# Docker
docker run aquasec/trivy image [OPTIONS] IMAGE_NAME
```

### Verify Installation
```bash
trivy version
trivy image --help
```

## Basic Scanning

### 1. Scan Local Image
```bash
# Scan image from local Docker daemon
trivy image myapp:latest

# Output:
# 2024-01-15T10:30:45.123Z	INFO	Number of language-specific files: 0
# 2024-01-15T10:30:45.200Z	INFO	Detecting OS and scanning vulnerabilities...
# ...
# myapp:latest (ubuntu 20.04)
# ===============================
# Total: 12 (CRITICAL: 2, HIGH: 5, MEDIUM: 5)
```

### 2. Scan Remote Image (Registry)
```bash
# ECR
trivy image 123456789.dkr.ecr.us-east-1.amazonaws.com/myapp:latest

# Docker Hub
trivy image alpine:latest

# Private Registry (with auth)
trivy image \
  --username $DOCKER_USER \
  --password $DOCKER_PASS \
  myregistry.azurecr.io/app:v1.0
```

### 3. Exit Code Control
```bash
# Fail if CRITICAL vulnerabilities found
trivy image --exit-code 1 --severity CRITICAL myapp:latest

# Exit codes:
# 0 = No vulnerabilities
# 1 = Vulnerabilities found (matches --severity)
```

## Output Formats

### 1. Table (Default)
```bash
trivy image myapp:latest
```

Output:
```
myapp:latest (ubuntu 20.04)
=============================

Vulnerabilities
───────────────
ID            Severity  Installed  Fixed      Package
──────────────────────────────────────────────────────
CVE-2021-1234 CRITICAL  1.2.3      1.2.5      openssl
CVE-2021-5678 HIGH      2.0.0      2.0.2      libssl-dev
```

### 2. JSON Format
```bash
trivy image --format json --output report.json myapp:latest

# Extract specific info
jq '.Results[0].Misconfigurations' report.json
```

### 3. SARIF Format (for GitHub)
```bash
trivy image --format sarif --output report.sarif myapp:latest
# Upload to GitHub Security tab
```

### 4. SBOM (Software Bill of Materials)
```bash
trivy image --format cyclonedx --output sbom.json myapp:latest
```

## Severity Levels

| Level | Risk | Action |
|-------|------|--------|
| CRITICAL | Immediate | Block deployment |
| HIGH | Urgent | Require approval |
| MEDIUM | Moderate | Monitor |
| LOW | Low | Informational |
| UNKNOWN | Unknown | Review case-by-case |

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  trivy-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Run Trivy scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ secrets.REGISTRY }}/myapp:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'

      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```

### GitLab CI Example

```yaml
security_scan:
  image: aquasec/trivy:latest
  script:
    - trivy image 
        --exit-code 0 
        --severity CRITICAL,HIGH 
        --format json 
        --output gl-container-scanning-report.json 
        $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  artifacts:
    reports:
      container_scanning: gl-container-scanning-report.json
```

### Docker Build Integration

```dockerfile
# Multi-stage: Build + Scan
FROM node:18-alpine AS build
WORKDIR /app
COPY . .
RUN npm install && npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=build /app/dist .
EXPOSE 3000
CMD ["node", "server.js"]

# Scan after build
# docker build -t myapp:latest .
# docker run aquasec/trivy image myapp:latest
```

## Vulnerability Management

### 1. Ignore CVEs (Exception Policy)
Create `.trivyignore` file:

```
# Ignore specific CVEs
CVE-2021-1234
CVE-2021-5678

# Ignore by package
# package: curl

# Ignore expiry date
# expiry: 2024-12-31
CVE-2023-9999 exp:2025-12-31
```

Usage:
```bash
trivy image --ignorefile .trivyignore myapp:latest
```

### 2. Policy-based Scanning

Create `trivy-policy.rego` (OPA/Rego):

```rego
package trivy

default allow = false

allow {
  input.Severity != "CRITICAL"
}

deny[msg] {
  input.Severity == "CRITICAL"
  msg := sprintf("CRITICAL CVE not allowed: %s", [input.VulnerabilityID])
}

deny[msg] {
  input.PkgName == "openssl"
  input.InstalledVersion < "1.1.1"
  msg := sprintf("OpenSSL must be >= 1.1.1, found: %s", [input.InstalledVersion])
}
```

Apply policy:
```bash
trivy image --format json myapp:latest | \
  opa eval -d trivy-policy.rego -i - 'data.trivy.allow'
```

## Advanced: Database Management

### 1. Update Vulnerability Database
```bash
# Auto-update (runs on first scan)
trivy image myapp:latest

# Manual update
trivy image --download-db-only

# Skip update
trivy image --skip-update myapp:latest
```

### 2. Offline Scanning

```bash
# On online machine: Download DB
trivy image --download-db-only --db-repository \
  registry.example.com/trivy-db

# Transfer to offline machine
scp trivy-db /offline-machine:/opt/

# On offline machine: Use downloaded DB
trivy image \
  --skip-update \
  --db-repository registry.example.com/trivy-db \
  myapp:latest
```

### 3. Custom Database

```bash
# Use custom vulnerability source
trivy image \
  --db-repository registry.example.com/trivy-db \
  --severity CRITICAL,HIGH \
  myapp:latest
```

## Hands-on Lab

### 1. Scan Public Image (Known Vulnerable)
```bash
# ubuntu:20.04 typically has known vulnerabilities
trivy image ubuntu:20.04

# Output shows CVEs with details
```

### 2. Scan Your App
```bash
# Build and scan
docker build -t myapp:v1.0 .
trivy image myapp:v1.0

# Generate JSON report
trivy image --format json --output scan-report.json myapp:v1.0
jq '.Results[] | select(.Vulnerabilities != null) | .Vulnerabilities[]' scan-report.json
```

### 3. Create Exception Policy
```bash
# 1. Create .trivyignore
cat > .trivyignore <<EOF
# Approved after security review
CVE-2021-1234

# Temporary - expires after 30 days
CVE-2024-0001 exp:2024-07-15
EOF

# 2. Scan with policy
trivy image --ignorefile .trivyignore myapp:latest
```

### 4. CI Integration
```bash
# Simulate CI
docker build -t myapp:test .
trivy image \
  --exit-code 1 \
  --severity CRITICAL,HIGH \
  --format sarif \
  --output trivy-report.sarif \
  myapp:test

echo "Exit code: $?"
```

## Best Practices

1. **CI/CD Integration**: Scan on every build
   ```yaml
   # In CI pipeline
   - Run: trivy image $IMAGE:$TAG --exit-code 1
   ```

2. **Baseline**: Don't block on first scan, establish baseline
   ```bash
   # Week 1: Report only
   trivy image --exit-code 0 myapp:latest
   
   # Week 2+: Enforce
   trivy image --exit-code 1 myapp:latest
   ```

3. **Exception Management**: Track approved CVEs
   - Document reason for exception
   - Set expiry dates
   - Regular review

4. **Registry Scanning**: Continuous scanning
   - Use Trivy Server for registry scanning
   - Notify on new vulnerabilities
   - Automated compliance checks

5. **Dependency Updates**: Regular maintenance
   - Monitor security advisories
   - Update base images frequently
   - Pin versions carefully

## Common Issues

| Issue | Solution |
|-------|----------|
| Scan too slow | Use `--skip-update` if DB recent, reduce `--severity` |
| Too many false positives | Create `.trivyignore` policy |
| Can't access registry | Provide docker login credentials |
| Database not found | Run with `--download-db-only` first |

---

**Next**: → 05-cosign-signing.md
