# External Secrets Operator (ESO) - K8s Secret Sync

## Overview
External Secrets Operator là K8s operator tự động sync secrets từ external systems (AWS Secrets Manager, HashiCorp Vault, etc.) vào K8s cluster mà không restart pods.

**Key Features**:
- Multi-backend support (AWS, GCP, Azure, Vault)
- Automatic sync + rotation
- No pod restart required (volume mount)
- Templating secrets
- Multi-secret composition

## Installation

### 1. Add Helm Repository
```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
```

### 2. Install ESO
```bash
helm install external-secrets \
  external-secrets/external-secrets \
  -n external-secrets \
  --create-namespace \
  --set installCRDs=true \
  --values values.yaml
```

### values.yaml Example
```yaml
serviceAccount:
  create: true
  name: external-secrets-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT_ID:role/external-secrets-role

securityContext:
  runAsNonRoot: true
  runAsUser: 65534

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### 3. Verify Installation
```bash
kubectl get pods -n external-secrets
kubectl get crds | grep external
# Expected CRDs:
# - secretstores.external-secrets.io
# - externalsecrets.external-secrets.io
# - clustersecretstores.external-secrets.io
```

## Core Components

### 1. SecretStore (Namespace-scoped)
Định nghĩa cách kết nối đến external secret backend:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets
  namespace: default
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
```

### 2. ClusterSecretStore (Cluster-scoped)
Reusable across all namespaces:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: aws-secrets-global
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
            namespace: external-secrets
```

### 3. ExternalSecret
Định nghĩa secret nào sync từ backend:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-database
  namespace: default
spec:
  refreshInterval: 1h  # Sync frequency
  secretStoreRef:
    name: aws-secrets
    kind: SecretStore
  target:
    name: app-database  # K8s secret name
    creationPolicy: Owner
    template:
      type: Opaque
      metadata:
        labels:
          app: myapp
      data:
        # Template engine support
        connection_string: "postgresql://{{ .username }}:{{ .password }}@{{ .host }}:5432/{{ .db }}"
  
  data:
    # Sync single key from AWS secret
    - secretKey: username
      remoteRef:
        key: k8s/database/username
    
    - secretKey: password
      remoteRef:
        key: k8s/database/password
        version: AWSCURRENT  # Version label
    
    - secretKey: host
      remoteRef:
        key: k8s/database/host
  
  dataFrom:
    # Sync entire secret (JSON with multiple keys)
    - extract:
        key: k8s/database/credentials  # AWS secret contains {"username": "...", "password": "..."}
```

## Rotation ohne Pod Restart

**How it works**:
1. ESO watches external secret
2. Detects version change (new rotation)
3. Updates K8s secret
4. Pod mounts secret via volume → sees new values
5. Pod continues running (no restart)

**Requirements**:
- Pod mounts secret as volume (NOT environment variable)
- Application reloads config from file

### Example: Database Pod with Rotating Secret

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database-app
spec:
  containers:
  - name: app
    image: myapp:latest
    volumeMounts:
    - name: db-secret
      mountPath: /etc/secrets
      readOnly: true
    env:
    - name: DB_CONFIG_PATH
      value: /etc/secrets/connection_string
    # Application reads from /etc/secrets/connection_string
    # When ESO updates, app sees new value next read
  
  volumes:
  - name: db-secret
    secret:
      secretName: app-database  # Managed by ExternalSecret
```

### Rotation Flow

```
1. AWS Secrets Manager rotate password
   └─ new version created (AWSCURRENT points to new)

2. ESO detects change (refreshInterval check)
   └─ Pulls new secret value

3. K8s Secret updated
   └─ app-database secret gets new data

4. Pod sees new value (volume mount)
   └─ No restart needed!
   └─ App reads new credentials next request

Timeline: < 60 seconds if refreshInterval: 60s
```

## Templating Secrets

Compose multiple secrets into one:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
spec:
  secretStoreRef:
    name: aws-secrets
  target:
    name: app-secrets
    template:
      type: Opaque
      data:
        # Combine multiple external secrets
        database_url: "postgresql://{{ .db_user }}:{{ .db_pass }}@{{ .db_host }}/{{ .db_name }}"
        api_key: "{{ .api_key }}"
        tls_cert: |-
          {{ .cert_pem }}
  
  data:
  - secretKey: db_user
    remoteRef:
      key: k8s/db/user
  - secretKey: db_pass
    remoteRef:
      key: k8s/db/password
  - secretKey: db_host
    remoteRef:
      key: k8s/db/host
  - secretKey: db_name
    remoteRef:
      key: k8s/db/name
  - secretKey: api_key
    remoteRef:
      key: k8s/app/api_key
  - secretKey: cert_pem
    remoteRef:
      key: k8s/tls/cert
```

## Multi-backend Example

```yaml
---
# AWS Secrets
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-store
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
---
# HashiCorp Vault
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-store
spec:
  provider:
    vault:
      server: "https://vault.example.com:8200"
      path: "secret"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "external-secrets"
---
# Compose from both
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: combined-secret
spec:
  target:
    name: app-config
  
  data:
  # From AWS
  - secretKey: db_password
    remoteRef:
      key: k8s/db/password
    secretStoreRef:
      name: aws-store
  
  # From Vault
  - secretKey: vault_token
    remoteRef:
      key: app/token
    secretStoreRef:
      name: vault-store
```

## Monitoring ESO

```bash
# Check ExternalSecret status
kubectl describe externalsecret app-database

# View sync status
kubectl get externalsecrets -A -o wide

# View events
kubectl get events -n default --field-selector involvedObject.kind=ExternalSecret

# Logs
kubectl logs -n external-secrets deployment/external-secrets
```

## Troubleshooting

| Issue | Debug |
|-------|-------|
| Secret not syncing | `kubectl describe externalsecret NAME` → check Status |
| AccessDenied | Verify IAM role + SecretStore auth |
| TemplateError | Check template syntax in ExternalSecret |
| RefreshInterval too short | Monitor API rate limits |

## Hands-on Lab

```bash
# 1. Install ESO
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace --set installCRDs=true

# 2. Create AWS secret
aws secretsmanager create-secret \
  --name k8s/app/database \
  --secret-string '{"username":"admin","password":"secret123"}'

# 3. Create SecretStore
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
EOF

# 4. Create ExternalSecret
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-db
spec:
  refreshInterval: 60s
  secretStoreRef:
    name: aws-secrets
  target:
    name: app-db
  data:
  - secretKey: username
    remoteRef:
      key: k8s/app/database
      property: username
  - secretKey: password
    remoteRef:
      key: k8s/app/database
      property: password
EOF

# 5. Verify K8s secret created
kubectl get secret app-db -o jsonpath='{.data.username}' | base64 -d
```

---

**Next**: → 04-trivy-image-scan.md
