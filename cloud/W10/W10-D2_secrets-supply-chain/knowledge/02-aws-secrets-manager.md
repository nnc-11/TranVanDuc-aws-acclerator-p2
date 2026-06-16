# AWS Secrets Manager - Centralized Secret Management

## Overview
AWS Secrets Manager là dịch vụ quản lý secrets tập trung trên AWS với khả năng:
- Store secrets (passwords, API keys, database credentials)
- Rotate secrets tự động
- Audit trail đầy đủ
- IAM policy integration
- Multi-region replication

## Arch Pattern

```
┌─────────────────────────────────────────┐
│   AWS Secrets Manager (AWS Account)     │
│  ┌─────────────────────────────────────┤
│  │ Secret: db-password                 │
│  │ - Version: v1 (current)             │
│  │ - Version: v2 (staging)             │
│  │ - Rotation: 30 days                 │
│  │ - Lambda: rotation function         │
│  └─────────────────────────────────────┤
│  Audit: ✓ CloudTrail logging           │
└─────────────────────────────────────────┘
        ↑
        │ (External Secrets Operator)
        │
    K8s Cluster
    ┌──────────────────────────────────┐
    │ SecretStore (AWS auth)           │
    │ ExternalSecret resource          │
    │   ↓                              │
    │ K8s Secret (auto-sync)           │
    │ Pod mounts volume → SECRET ✓     │
    └──────────────────────────────────┘
```

## AWS Secrets Manager Setup

### 1. IAM Policy cho ESO
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:*:ACCOUNT_ID:secret:k8s/*"
    }
  ]
}
```

### 2. Create Secret trong AWS Console hoặc CLI

```bash
# CLI: Tạo secret
aws secretsmanager create-secret \
  --name k8s/database/password \
  --secret-string "my-super-secret-password" \
  --region us-east-1

# List secrets
aws secretsmanager list-secrets --region us-east-1

# Get secret value
aws secretsmanager get-secret-value \
  --secret-id k8s/database/password \
  --region us-east-1
```

### 3. Setup AWS Credentials cho K8s (2 options)

**Option A: IAM Role for Service Accounts (IRSA)** - Recommended
```bash
# Create IAM role + bind to K8s service account
eksctl create iamserviceaccount \
  --cluster=my-cluster \
  --name=external-secrets-sa \
  --namespace=external-secrets \
  --role-name=external-secrets-role \
  --attach-policy-arn=arn:aws:iam::ACCOUNT_ID:policy/SecretsManagerAccess
```

**Option B: AWS Access Keys (Not recommended)**
```bash
# Create IAM user với Secrets Manager permissions
# Generate access key
# Tạo K8s secret:
kubectl create secret generic aws-secrets \
  --from-literal=access-key=AKIAIOSFODNN7EXAMPLE \
  --from-literal=secret-key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
  -n external-secrets
```

## Secret Rotation Strategies

### 1. Automatic Rotation (Lambda-based)
AWS Secrets Manager tự động rotate secret:
- Define rotation function (Lambda)
- Rotation schedule (e.g., 30 days)
- Backup secret trước rotate
- Update target resource (database, etc.)

### 2. Manual Rotation
```bash
# Update secret value
aws secretsmanager update-secret \
  --secret-id k8s/database/password \
  --secret-string "new-password"

# Verify version
aws secretsmanager describe-secret --secret-id k8s/database/password
```

### 3. With Database Auto-Rotation
Ví dụ: PostgreSQL password rotation
```bash
# Lambda function handles:
# 1. ALTER USER password
# 2. Update secret in Secrets Manager
# 3. Test connection
# 4. Finalize rotation
```

## Best Practices

1. **Naming Convention**
   ```
   k8s/{environment}/{app}/{secret-type}
   Example: k8s/prod/api/database-password
   ```

2. **IAM Principle of Least Privilege**
   - Specify resource ARN patterns
   - Limit to specific secret names
   - Use namespace separation in naming

3. **Encryption**
   - Use AWS KMS for at-rest encryption
   - Specify KMS key in secret creation
   - Audit key usage with CloudTrail

4. **Versioning**
   ```bash
   # Track versions
   aws secretsmanager list-secret-version-ids \
     --secret-id k8s/database/password
   ```

5. **Multi-Region**
   ```bash
   # Replicate secret to multiple regions
   aws secretsmanager replicate-secret-to-regions \
     --secret-id k8s/database/password \
     --add-replica-regions RegionCode=eu-west-1
   ```

## CloudTrail Audit
```
GetSecretValue → Log entry:
- Who: IAM role, timestamp
- What: Secret accessed, version
- Where: IP address, user agent
- Result: Success/Failure
```

## Hands-on: Create Your First Secret

```bash
# 1. Create secret
aws secretsmanager create-secret \
  --name k8s/app/api-key \
  --secret-string "$(openssl rand -base64 32)"

# 2. Retrieve secret
aws secretsmanager get-secret-value \
  --secret-id k8s/app/api-key \
  --query SecretString

# 3. Rotate (update version)
aws secretsmanager update-secret \
  --secret-id k8s/app/api-key \
  --secret-string "$(openssl rand -base64 32)"

# 4. View rotation history
aws secretsmanager describe-secret --secret-id k8s/app/api-key
```

## Common Issues

| Issue | Solution |
|-------|----------|
| AccessDenied | Check IAM policy attached to role |
| InvalidRequestException | Verify secret name exists |
| DecryptionFailure | KMS key accessible, check KMS policy |
| ResourceNotFoundException | Secret doesn't exist, create it |

---

**Next**: → 03-external-secrets-operator.md
