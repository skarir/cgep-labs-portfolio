# Lab 4.3: GRC Evidence Pipeline

**CGE-P Certification Lab** | Governance, Risk & Compliance | Evidence Automation

---

## Overview

Lab 4.3 creates a **complete GRC evidence pipeline** that integrates:
- **Lab 2.3** S3 infrastructure (compliance-by-default)
- **Lab 2.5** Evidence collection (automated archival)
- **Lab 3.4** Policy validation (compliance-as-code)
- **New:** GRC Dashboard (compliance reporting)

The result is an end-to-end system where compliance evidence flows from infrastructure → collection → validation → reporting, **without manual intervention**.

---

## Learning Objectives

By completing this lab, you will:

✅ Integrate evidence sources into a unified pipeline  
✅ Create GRC dashboards with compliance metrics  
✅ Implement automated compliance scoring  
✅ Generate audit-ready reports  
✅ Build control mapping dashboards  
✅ Understand GRC workflow automation  

---

## Architecture

```
INFRASTRUCTURE (Lab 2.3)
        ↓
    S3 Buckets (encrypted, logged, versioned)
        ↓
EVIDENCE COLLECTION (Lab 2.5)
        ↓
    Lambda: Collect → Archive → Verify
        ↓
POLICY VALIDATION (Lab 3.4)
        ↓
    Conftest: Validate → Score → Report
        ↓
GRC PIPELINE (Lab 4.3)
        ↓
    ├─ DynamoDB: Control Status Tracking
    ├─ CloudWatch: Compliance Dashboards
    ├─ EventBridge: Workflow Orchestration
    └─ SNS: Compliance Notifications
        ↓
COMPLIANCE REPORTING
        ↓
    JSON/CSV Reports → Audit Submission
```

---

## Components

### 1. Control Status Tracking (DynamoDB)

| Field | Type | Purpose |
|-------|------|---------|
| ControlID | String | SC-28(1), AU-3(1), etc. |
| Status | String | COMPLIANT, NON-COMPLIANT, NOT-TESTED |
| EvidenceID | String | Reference to evidence in Lab 2.5 |
| LastVerified | String | ISO timestamp of last verification |
| ComplianceScore | Number | 0-100 score based on evidence |

### 2. EventBridge Orchestration

```
Daily Schedule (2:30 AM UTC)
        ↓
        ├─ Trigger Lab 2.5 Evidence Collection
        ├─ Wait for completion (Step Functions)
        ├─ Trigger Lab 3.4 Policy Validation
        ├─ Update control status in DynamoDB
        ├─ Generate compliance score
        └─ Send SNS notification
```

### 3. Compliance Scoring

```
Score = (Controls Compliant / Total Controls) × 100

Example:
  4 compliant controls out of 5
  Score = (4/5) × 100 = 80%
```

### 4. Audit Report Generation

```json
{
  "audit_date": "2026-05-22",
  "framework": "NIST 800-53",
  "total_controls": 5,
  "compliant_controls": 4,
  "non_compliant_controls": 1,
  "compliance_score": 80,
  "controls": [
    {
      "control_id": "SC-28(1)",
      "status": "COMPLIANT",
      "evidence": "s3://evidence-archive/lab23-evidence/...",
      "verified_date": "2026-05-22"
    }
  ]
}
```

---

## Prerequisites

- [ ] Lab 2.3 deployed and verified
- [ ] Lab 2.5 evidence collection working
- [ ] Lab 3.4 Conftest policies created
- [ ] AWS Account with Step Functions, EventBridge permissions

---

## Implementation Files

### Lambda: Evidence Aggregator

```python
"""
Aggregates evidence from Lab 2.5
Validates with Lab 3.4 policies
Updates compliance score in DynamoDB
"""
import json
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    table = dynamodb.Table('grc-control-status')
    
    # Query all evidence from DynamoDB (Lab 2.5)
    response = table.query(KeyConditionExpression='ControlID = :cid',
                          ExpressionAttributeValues={':cid': 'ALL'})
    
    compliant = 0
    for item in response['Items']:
        if item['Status'] == 'COMPLIANT':
            compliant += 1
    
    # Calculate score
    score = int((compliant / len(response['Items'])) * 100)
    
    # Update dashboard
    table.put_item(Item={
        'ControlID': 'OVERALL',
        'Timestamp': datetime.utcnow().isoformat(),
        'ComplianceScore': score
    })
    
    return {'statusCode': 200, 'score': score}
```

### EventBridge Rule: Daily Orchestration

```json
{
  "Name": "grc-evidence-pipeline-daily",
  "ScheduleExpression": "cron(0 2 * * ? *)",
  "Targets": [
    {
      "Arn": "arn:aws:states:us-east-1:ACCOUNT:stateMachine:grc-pipeline",
      "RoleArn": "arn:aws:iam::ACCOUNT:role/eventbridge-role"
    }
  ]
}
```

### CloudWatch Dashboard

```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", 
           {"stat": "Sum", "label": "Evidence Updates"}],
          ["AWS/Lambda", "Invocations",
           {"stat": "Sum", "label": "Collections"}]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "GRC Evidence Pipeline Activity"
      }
    },
    {
      "type": "custom",
      "properties": {
        "markdown": "# Compliance Score: 80%\n\n- SC-28(1): ✓\n- AU-3(1): ✓\n- AU-6(1): ✓\n- AC-3(1): ✓\n- CM-6(1): ✗"
      }
    }
  ]
}
```

---

## Deployment Steps

### Step 1: Create Control Status Table

```bash
aws dynamodb create-table \
  --table-name grc-control-status \
  --attribute-definitions \
    AttributeName=ControlID,AttributeType=S \
    AttributeName=Timestamp,AttributeType=S \
  --key-schema \
    AttributeName=ControlID,KeyType=HASH \
    AttributeName=Timestamp,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST
```

### Step 2: Deploy Aggregator Lambda

```bash
zip -r aggregator.zip lambda_aggregator.py
aws lambda create-function \
  --function-name grc-aggregator \
  --runtime python3.11 \
  --handler lambda_aggregator.lambda_handler \
  --zip-file fileb://aggregator.zip \
  --role arn:aws:iam::ACCOUNT:role/lambda-role
```

### Step 3: Create EventBridge Rule

```bash
aws events put-rule \
  --name grc-pipeline-daily \
  --schedule-expression "cron(30 2 * * ? *)" \
  --state ENABLED
```

---

## Verification

### Check Compliance Score

```bash
aws dynamodb get-item \
  --table-name grc-control-status \
  --key '{"ControlID":{"S":"OVERALL"}}'
```

Expected: `ComplianceScore: 80` (or your current score)

### View CloudWatch Dashboard

```bash
aws cloudwatch get-dashboard --dashboard-name GRC-Pipeline
```

### Test Pipeline Manually

```bash
aws lambda invoke --function-name grc-aggregator response.json
cat response.json
```

---

## Success Criteria

All criteria must be met:

### ✅ Control Status Table Exists
```bash
aws dynamodb describe-table --table-name grc-control-status
```

### ✅ Aggregator Lambda Deployed
```bash
aws lambda get-function --function-name grc-aggregator
```

### ✅ EventBridge Rule Created
```bash
aws events describe-rule --name grc-pipeline-daily
```

### ✅ Compliance Score Updated
```bash
aws dynamodb get-item --table-name grc-control-status \
  --key '{"ControlID":{"S":"OVERALL"}}' | grep ComplianceScore
```

---

## Interview Talking Points

**"How do you measure compliance?"**
> "I have an automated GRC pipeline that continuously evaluates compliance. Every control is tested, evidence is collected, and a compliance score (0-100%) is calculated daily. The score is based on actual evidence, not manual self-assessment."

**"What happens if a control fails?"**
> "EventBridge detects the failure and sends SNS notifications to the compliance team. The control status is updated in DynamoDB, and a report is generated automatically. The team can then investigate the root cause."

**"How do you prepare for audits?"**
> "The audit report is pre-generated from the pipeline. I don't need to manually collect evidence or write assessments. The auditor can review the report immediately."

---

## Next Lab

**Lab 7.1: Capstone** integrates this entire pipeline with additional security baselines (Labs 5.2, 5.4) and OSCAL documentation (Lab 6.1) for a complete compliance solution.

---

**Estimated Time:** 30-45 minutes  
**Difficulty:** Advanced  
**AWS Cost:** <$0.05/month (DynamoDB on-demand)  

---

*Lab 4.3 created for CGE-P Certification*  
*Date: May 22, 2026*
