# Cosign - Container Image Signing & Verification

## Overview
Cosign là công cụ từ Sigstore project cho phép ký container images và verify signatures, hỗ trợ:
- **Keyless signing**: OIDC provider (GitHub, Google, Azure AD) - không cần manage private keys
- **Key-based signing**: Traditional public/private key pairs
- **Attestations**: Sign metadata, test results, SBOMs
- **Supply chain**: Track image provenance

## Installation

```bash
# macOS
brew install sigstore/tap/cosign

# Linux
wget https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
chmod +x cosign-linux-amd64 && sudo mv cosign-linux-amd64 /usr/local/bin/cosign

# Docker
docker run gcr.io/projectsigstore/cosign:latest
```

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│  Image Signing Flow                         │
├─────────────────────────────────────────────┤
│                                             │
│  Image (myapp:latest)                       │
│    ↓                                        │
│  [Sign with Cosign]                         │
│    ├─ Hash image digest                     │
│    ├─ Sign with private key or OIDC         │
│    └─ Push signature to registry             │
│    ↓                                        │
│  Signature stored (separate blob)           │
│    ├─ Location: registry.io/myapp:sha256-...  │
│    ├─ Contains: public key, signature       │
│    └─ Discoverable: image digest            │
│                                             │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  Image Verification Flow                    │
├─────────────────────────────────────────────┤
│                                             │
│  Pod request: myapp:latest                  │
│    ↓                                        │
│  [Admission Controller]                     │
│    ├─ Resolve digest (latest → sha256:abc)  │
│    ├─ Search for signature                  │
│    ├─ Verify signature (OIDC or key)        │
│    └─ Check certificate chain                │
│    ↓                                        │
│  Result: ✓ Allow / ✗ Reject                 │
│                                             │
└─────────────────────────────────────────────┘
```

## Strategy 1: Keyless Signing (OIDC)

### How Keyless Works

1. Developer runs `cosign sign` locally
2. Cosign redirects to browser → OIDC provider (GitHub)
3. User authenticates → gets identity token
4. Token proves: "user@company.com signed this at 2024-01-15 10:30:00"
5. Signature stored + image remains unchanged

**Advantages**:
- No private key management
- Identity tied to OIDC provider
- Audit trail automatic
- Easy rotation (provider handles it)

**Disadvantages**:
- Requires OIDC provider setup
- Network call to OIDC provider during signing
- Not suitable for headless/CI (use CI-OIDC instead)

### Keyless Signing (GitHub OIDC in CI)

```yaml
# GitHub Actions workflow
name: Build & Sign

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write  # Required for OIDC token
      packages: write
    steps:
      - uses: actions/checkout@v3

      - name: Build image
        run: |
          docker build -t ghcr.io/${{ github.repository }}:${{ github.sha }} .
          docker push ghcr.io/${{ github.repository }}:${{ github.sha }}

      - name: Install Cosign
        uses: sigstore/cosign-installer@v3

      - name: Sign image with keyless OIDC
        run: |
          cosign sign --yes \
            ghcr.io/${{ github.repository }}:${{ github.sha }}
        env:
          COSIGN_EXPERIMENTAL: 1
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Local Keyless Signing

```bash
# Prerequisites: GitHub account + 'gh' CLI authenticated
gh auth login

# Sign image interactively (opens browser)
cosign sign --yes \
  myregistry.azurecr.io/myapp:latest

# Environment variable enables keyless mode
export COSIGN_EXPERIMENTAL=1
cosign sign --yes myregistry.azurecr.io/myapp:latest

# Verify signature
cosign verify --certificate-identity "user@company.com" \
  myregistry.azurecr.io/myapp:latest
```

## Strategy 2: Key-Based Signing

### Generate Key Pairs

```bash
# Generate RSA keys (default)
cosign generate-key-pair

# Output:
# ✓ Private key written to cosign.key
# ✓ Public key written to cosign.pub

# Generate ECDSA keys (smaller, faster)
cosign generate-key-pair --kms gcpkms://...

# Verify key
cosign public-key --key cosign.key
```

### Sign with Private Key

```bash
# Sign image
cosign sign --key cosign.key \
  myregistry.azurecr.io/myapp:v1.0

# Sign with key stored in KMS (AWS, GCP, Azure)
cosign sign --key awskms://arn:aws:kms:us-east-1:ACCOUNT:key/UUID \
  myregistry.azurecr.io/myapp:v1.0
```

### Verify Signature

```bash
# Verify with public key
cosign verify --key cosign.pub \
  myregistry.azurecr.io/myapp:v1.0

# Output:
# Verification successful!
# Signature Details:
# - Digest: sha256:abc123...
# - Key ID: 123abc...
# - Timestamp: 2024-01-15T10:30:00Z

# Verify from specific certificate identity
cosign verify \
  --certificate-identity "user@company.com" \
  --certificate-oidc-issuer "https://github.com/login/oauth" \
  myregistry.azurecr.io/myapp:v1.0
```

## Attestations (Sign Metadata)

Store additional metadata (test results, SBOM) along with signature:

```bash
# Sign and attach attestation (e.g., test results)
cosign attest --key cosign.key \
  --predicate test-results.json \
  --predicate-type https://example.com/test/v1 \
  myregistry.azurecr.io/myapp:v1.0

# Verify attestation
cosign verify-attestation --key cosign.pub \
  myregistry.azurecr.io/myapp:v1.0

# Extract attestation
cosign verify-attestation --key cosign.pub \
  myregistry.azurecr.io/myapp:v1.0 | jq '.payload | @base64d | fromjson'
```

### Attestation Example: SBOM + CVE Scan

```yaml
# In CI pipeline
- name: Generate SBOM
  run: |
    syft myapp:latest -o json > sbom.json

- name: Scan for vulnerabilities
  run: |
    trivy image --format json --output trivy.json myapp:latest

- name: Create attestation
  run: |
    # Combine SBOM + Trivy results
    jq -s '{sbom: .[0], vulnscan: .[1]}' sbom.json trivy.json > attestation.json

- name: Sign with attestation
  run: |
    cosign attest --key cosign.key \
      --predicate attestation.json \
      --predicate-type https://example.com/supply-chain/v1 \
      myregistry.azurecr.io/myapp:${{ github.sha }}
```

## Supply Chain Security (end-to-end)

### Complete CI/CD Flow

```yaml
name: Secure Build & Push

on: push

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
      packages: write
    steps:
      # 1. Build image
      - uses: actions/checkout@v3
      - uses: docker/setup-buildx-action@v2
      - name: Build & push
        uses: docker/build-push-action@v4
        with:
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE }}:${{ github.sha }}

      # 2. Scan image
      - name: Trivy scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE }}:${{ github.sha }}
          format: 'json'
          output: 'trivy-results.json'
          severity: 'CRITICAL,HIGH'

      # 3. Generate SBOM
      - uses: anchore/sbom-action@v0
        with:
          image: ${{ env.REGISTRY }}/${{ env.IMAGE }}:${{ github.sha }}
          format: json
          output-file: sbom.json

      # 4. Sign image + attach attestations
      - uses: sigstore/cosign-installer@v3
      - name: Sign & attest
        run: |
          # Combine scan results
          jq -s '{
            sbom: .[0],
            vulnscan: .[1],
            source: "github.com/${{ github.repository }}",
            commit: "${{ github.sha }}"
          }' sbom.json trivy-results.json > attestation.json
          
          # Sign with keyless OIDC
          cosign sign --yes \
            ${{ env.REGISTRY }}/${{ env.IMAGE }}:${{ github.sha }}
          
          # Attach attestation
          cosign attest --yes \
            --predicate attestation.json \
            --predicate-type https://example.com/supply-chain/v1 \
            ${{ env.REGISTRY }}/${{ env.IMAGE }}:${{ github.sha }}
        env:
          COSIGN_EXPERIMENTAL: 1
```

## Best Practices

1. **Private Key Protection**
   ```bash
   # Encrypt key with password
   cosign generate-key-pair
   # Enter password when prompted
   
   # Use KMS for key storage (AWS, GCP, Azure)
   cosign sign --key awskms://... image
   ```

2. **Key Rotation**
   ```bash
   # Generate new key pair
   cosign generate-key-pair-2
   
   # Update admission controller to accept both keys
   # Gradually phase out old key
   ```

3. **Audit Trail**
   ```bash
   # Signatures include timestamp + identity
   cosign verify --key cosign.pub myimage:tag | jq '.metadata'
   ```

4. **Registry Integration**
   - Store signatures in same registry as images
   - Use OCI image spec for signature storage
   - Enable registry immutability

## Hands-on Lab

```bash
# 1. Generate key pair
cosign generate-key-pair

# 2. Sign test image
cosign sign --key cosign.key \
  gcr.io/google-samples/hello-app:latest

# 3. Verify signature
cosign verify --key cosign.pub \
  gcr.io/google-samples/hello-app:latest

# 4. Try with keyless (requires GitHub auth)
export COSIGN_EXPERIMENTAL=1
gh auth login
cosign sign --yes gcr.io/google-samples/hello-app:latest

# 5. Verify keyless signature
cosign verify \
  --certificate-identity-regexp ".*" \
  --certificate-oidc-issuer-regexp ".*" \
  gcr.io/google-samples/hello-app:latest
```

---

**Next**: → 06-admission-webhook.md
