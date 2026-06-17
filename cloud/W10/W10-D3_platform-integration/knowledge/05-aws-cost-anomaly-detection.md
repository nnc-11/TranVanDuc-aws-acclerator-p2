# AWS Cost Anomaly Detection & Cost Guard

## Overview

Cost optimization is critical for sustainable cloud operations.
- **AWS Cost Anomaly Detection**: ML-based unexpected spending alerts
- **Cost Guard**: Platform-level cost policies
- **Resource Governance**: Limits from D3 Resource Quota
- **Observability Integration**: Cost metrics in monitoring stack

## AWS Cost Anomaly Detection

### What It Does

AWS Cost Anomaly Detection analyzes your spending patterns and alerts when:
- Spending exceeds normal patterns (ML-based)
- Specific services have unexpected costs
- Spending trends change suddenly
- Cost drivers shift

### Setup in AWS Console

#### 1. Enable Cost Anomaly Detection

```
AWS Console → AWS Cost Management → Anomaly Detection → Get Started
```

#### 2. Create Anomaly Monitor

```
Monitor Type: Dimensions
  - Dimension: Service
  - Dimension: Linked Account
  - Dimension: Region

Alert Frequency: Daily
```

#### 3. Create Anomaly Alert

```
Monitor: [Your monitor]
Frequency: Daily
Recipients: team@company.com

Alert Conditions:
  - Alert when anomaly confidence > 90%
  - Alert when estimated impact > $100
```

### Configuration via CloudFormation

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Cost Anomaly Detection Setup'

Resources:
  CostAnomalyMonitor:
    Type: AWS::CE::AnomalyMonitor
    Properties:
      MonitorName: Platform-Spend-Monitor
      MonitorType: DIMENSIONAL
      MonitorDimension: SERVICE
      
  AnomalySubscription:
    Type: AWS::CE::AnomalySubscription
    Properties:
      SubscriptionName: Platform-Cost-Alerts
      Threshold: 100  # $100 threshold
      Frequency: DAILY
      MonitorArnList:
        - !GetAtt CostAnomalyMonitor.MonitorArn
      SubscriptionArn:
        Fn::Sub: "arn:aws:sns:${AWS::Region}:${AWS::AccountId}:cost-alerts"
      Tags:
        - Key: Environment
          Value: production
```

### Terraform Configuration

```hcl
resource "aws_ce_anomaly_monitor" "platform" {
  monitor_name      = "platform-spend-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"

  tags = {
    Environment = "production"
  }
}

resource "aws_ce_anomaly_subscription" "alerts" {
  subscription_name = "platform-cost-alerts"
  threshold         = 100
  frequency         = "DAILY"
  
  monitor_arn_list = [
    aws_ce_anomaly_monitor.platform.arn
  ]

  sns_topic_arn = aws_sns_topic.cost_alerts.arn
}

resource "aws_sns_topic" "cost_alerts" {
  name = "cost-anomaly-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = "platform-team@company.com"
}
```

## Cost Guard - Platform Policy

### Goals
1. **Prevent Runaway Costs**: Limits on resource provisioning
2. **Enforce Tagging**: Track costs to teams
3. **Spot Usage**: Use cheaper instances where possible
4. **Resource Right-Sizing**: Match resources to actual usage

### Implementation

#### 1. Cost Policy in Platform Bootstrap

```yaml
# cost-guard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cost-policies
  namespace: platform
data:
  policies: |
    {
      "instance-types": {
        "allowed": ["t3.large", "t3.xlarge", "m5.large", "m5.xlarge"],
        "forbidden": ["m5.2xlarge", "m5.4xlarge"],
        "preferred": "t3.*"  # Burstable for cost efficiency
      },
      "storage": {
        "gp2-max-volume": "1000Gi",
        "max-snapshots-per-volume": 5,
        "retention-days": 30
      },
      "data-transfer": {
        "max-data-transfer": "1000Gi/month",
        "alert-threshold": "800Gi"
      },
      "instance-lifecycle": {
        "prefer-spot": true,
        "spot-interrupt-handler": true
      }
    }
```

#### 2. Cost Quota Admission Controller

```yaml
# cost-quota-webhook.yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: cost-guard
webhooks:
- name: cost-guard.platform.svc
  clientConfig:
    service:
      name: cost-guard
      namespace: platform
      path: "/validate"
    caBundle: LS0tLS1CRUdJ...
  rules:
  - operations: ["CREATE", "UPDATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods", "services"]
  admissionReviewVersions: ["v1"]
  sideEffects: None
  timeoutSeconds: 5
```

#### 3. Cost Policy Implementation

```python
# cost-guard-webhook.py
from flask import Flask, request, jsonify

app = Flask(__name__)

def validate_pod_cost(pod):
    """Validate pod resource requests against cost policies"""
    
    # 1. Check resource requests
    containers = pod.get('spec', {}).get('containers', [])
    for container in containers:
        resources = container.get('resources', {})
        
        # Check memory request - high memory = high cost
        memory = resources.get('requests', {}).get('memory', '128Mi')
        if parse_memory(memory) > parse_memory('8Gi'):
            return False, "Memory request exceeds cost policy"
        
        # Check CPU request
        cpu = resources.get('requests', {}).get('cpu', '100m')
        if parse_cpu(cpu) > parse_cpu('4'):
            return False, "CPU request exceeds cost policy"
    
    # 2. Check node affinity - prefer spot instances
    affinity = pod.get('spec', {}).get('affinity', {})
    node_selector = affinity.get('nodeAffinity', {})
    
    # Prefer cheaper availability zones
    required_terms = node_selector.get('requiredDuringSchedulingIgnoredDuringExecution', {})
    if not has_cost_optimization(required_terms):
        return False, "Pod should prefer spot/cheaper nodes"
    
    # 3. Check scheduling constraints
    spec = pod.get('spec', {})
    if 'terminationGracePeriodSeconds' not in spec:
        return False, "terminationGracePeriodSeconds required for graceful shutdown"
    
    return True, "Pod meets cost policies"

@app.route('/validate', methods=['POST'])
def validate():
    admission_review = request.get_json()
    
    pod = admission_review['request']['object']
    allowed, message = validate_pod_cost(pod)
    
    return jsonify({
        'apiVersion': 'admission.k8s.io/v1',
        'kind': 'AdmissionReview',
        'response': {
            'uid': admission_review['request']['uid'],
            'allowed': allowed,
            'status': {
                'message': message
            }
        }
    })

if __name__ == '__main__':
    app.run(ssl_context=('certs/tls.crt', 'certs/tls.key'))
```

## Cost Monitoring Integration

### Metrics Collection

```yaml
# cost-exporter.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cost-exporter
  namespace: platform
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cost-exporter
  template:
    metadata:
      labels:
        app: cost-exporter
    spec:
      serviceAccountName: cost-exporter
      containers:
      - name: exporter
        image: noldev/kube-cost-exporter:latest
        env:
        - name: CLUSTER_NAME
          value: "production"
        - name: AWS_REGION
          value: "ap-southeast-1"
        ports:
        - name: metrics
          containerPort: 9100
        volumeMounts:
        - name: config
          mountPath: /etc/exporter
      volumes:
      - name: config
        configMap:
          name: cost-exporter-config
```

### Prometheus Alerts for Cost

```yaml
groups:
- name: cost_management
  rules:
  # Pod resource over-provisioning
  - alert: PodMemoryOverProvisioned
    expr: |
      sum(rate(container_memory_usage_bytes[5m])) by (pod, namespace)
      / sum(container_spec_memory_limit_bytes) by (pod, namespace) < 0.2
    for: 1h
    annotations:
      summary: "Pod {{ $labels.pod }} over-provisioned on memory"
      action: "Consider reducing memory limit"
  
  # Service with LB but low traffic
  - alert: HighCostLowTraffic
    expr: |
      sum(rate(http_requests_total[5m])) by (service) < 10
      and on(service) service_type="LoadBalancer"
    for: 30m
    annotations:
      summary: "Service {{ $labels.service }} has LB but low traffic"
      action: "Consider NodePort instead of LB"
  
  # High egress data transfer
  - alert: HighDataEgress
    expr: |
      sum(rate(aws_ec2_network_out_bytes_total[5m]))
      > (1000 * 1024 * 1024)  # 1GB/s
    for: 5m
    annotations:
      summary: "High data egress - check for data leaks"
      
  # Spot instance termination
  - alert: SpotInstanceTerminated
    expr: |
      rate(aws_ec2_spot_interruption_count[5m]) > 0
    for: 1m
    annotations:
      summary: "Spot instance termination detected"
      action: "Verify cluster stability"
```

## Cost Optimization Strategies

### 1. Right-Sizing

```bash
# Analyze actual vs requested resources
kubectl top pods -n production --sort-by=memory
kubectl top pods -n production --sort-by=cpu

# Identify over-provisioned workloads
# Action: Reduce requests/limits to actual usage + 20% buffer
```

### 2. Spot Instances

```yaml
# Use Spot for non-critical workloads
apiVersion: apps/v1
kind: Deployment
metadata:
  name: batch-job
spec:
  template:
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: karpenter.sh/capacity-type
                operator: In
                values: ["spot"]
      # Graceful termination handler
      terminationGracePeriodSeconds: 120
```

### 3. Storage Optimization

```bash
# Clean up unused PVCs
kubectl get pvc -A --sort-by=.metadata.creationTimestamp

# Archive old snapshots
aws ec2 describe-snapshots --owner-ids self | \
  jq '.Snapshots | sort_by(.StartTime) | .[:-5]'  # Keep 5 latest

# Use EBS volume scheduling
# Cold storage → archive after 30 days
```

### 4. Reserved Instances (RI) Strategy

```
For stable workloads:
- Analyze 1-year usage patterns
- Purchase 1-year RIs for baseline load
- Use On-Demand for burst
- Savings: 30-40%
```

## D3 Cost Guard Roadmap

### Phase 1: Monitoring & Detection
- [ ] Enable AWS Cost Anomaly Detection
- [ ] Setup SNS notifications
- [ ] Create CloudWatch Cost dashboards
- [ ] Document spending baseline

### Phase 2: Policy Enforcement
- [ ] Implement cost admission controller
- [ ] Define resource limits per namespace
- [ ] Enforce tagging requirements
- [ ] Require cost center tags

### Phase 3: Optimization
- [ ] Identify over-provisioned workloads
- [ ] Migrate to Spot instances
- [ ] Archive cold storage
- [ ] Consolidate logging storage

### Phase 4: Automation
- [ ] Auto-right-sizing recommendations
- [ ] Automated cleanup of unused resources
- [ ] RI purchasing recommendations
- [ ] Cost showback reports

## Integration with W10 Platform

- **D1 RBAC**: Cost policies per role
- **D2 Secrets**: Secure credential rotation for AWS API access
- **D3 Cost Guard**: Central cost management
- **Runbooks**: Cost-related incident procedures
- **W11-12**: FinOps culture and automation

## Reports & Metrics

### Monthly Cost Report

```sql
-- AWS Athena query for cost analysis
SELECT
    bill_payer_account_id,
    linked_account_id,
    product_name,
    usage_type,
    SUM(CAST(unblended_cost AS decimal(10,2))) AS total_cost,
    SUM(CAST(usage_quantity AS decimal(10,2))) AS total_usage
FROM
    s3_cur_table
WHERE
    year = '2024'
    AND month = '06'
GROUP BY
    bill_payer_account_id,
    linked_account_id,
    product_name,
    usage_type
ORDER BY
    total_cost DESC
```

### Cost Attribution

```
Per Namespace Cost:
  - production: $5,000/month (60%)
  - staging: $2,000/month (25%)
  - development: $1,200/month (15%)

Per Team Cost:
  - Platform: $3,000/month
  - Data: $2,500/month
  - Frontend: $1,500/month
  - Backend: $1,200/month
```

## Next Steps

→ Setup cost anomaly detection
→ Create cost optimization dashboard
→ Define cost policies per team
→ Train team on cost awareness
