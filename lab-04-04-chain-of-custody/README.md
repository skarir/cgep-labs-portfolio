# Lab 4.4: Evidence Chain of Custody

**CGE-P Certification Lab** | Evidence Integrity & Audit Trail | SOC 2 Type II

---

## Overview

Lab 4.4 implements **chain-of-custody tracking** for compliance evidence - demonstrating who collected it, when, from where, whether it was verified, and how it's been protected. This is critical for regulatory audits (SOC 2 Type II, ISO 27001).

---

## Controls

| Control | Implementation |
|---------|-----------------|
| AU-12 | Log collection and control |
| SI-12 | Information handling and retention |
| CA-9 | Internal system connections |

---

## Architecture

```
Evidence Collection (Lab 2.5)
    ↓
DynamoDB Entry Created
    ├─ EvidenceID: unique-id
    ├─ Timestamp: collection-time
    ├─ Collector: lambda-function
    ├─ Status: COLLECTED
    ├─ Hash: SHA256
    └─ Signature: KMS-signed
    ↓
Evidence Verification (Lambda)
    ├─ Verify hash matches
    ├─ Verify signature
    ├─ Check completeness
    └─ Update status: VERIFIED
    ↓
DynamoDB Updated
    ├─ VerificationTime: timestamp
    ├─ Verifier: lambda-function
    ├─ Status: VERIFIED
    └─ VerificationHash: new-hash
    ↓
Evidence Archived (S3)
    ├─ S3 versioning enabled
    ├─ Lifecycle policy (7 years)
    ├─ Encryption (KMS)
    └─ Immutable (legal hold if needed)
```

---

## Implementation

### DynamoDB Chain of Custody Table

```python
{
  'EvidenceID': 'evidence-20260522-001',
  'Timestamp': '2026-05-22T02:00:00Z',
  'Source': 'Lab-2.3-S3-Bucket',
  'Collector': 'Lambda-evidence-collector',
  'CollectorRole': 'arn:aws:iam::ACCOUNT:role/lambda-role',
  'ArchiveLocation': 's3://evidence-archive/lab23-evidence/...',
  'Hash': 'sha256:abc123...',
  'Signature': 'kms-signed:xyz789...',
  'Status': 'COLLECTED',
  'Retention': {
    'RetentionDays': 2555,
    'ExpirationDate': '2033-05-22'
  },
  'Audit': {
    'VerifiedBy': 'Lambda-evidence-verifier',
    'VerificationTime': '2026-05-22T02:15:00Z',
    'VerificationStatus': 'VERIFIED',
    'VerificationHash': 'sha256:def456...'
  },
  'Access': [
    {
      'AccessTime': '2026-05-22T10:00:00Z',
      'AccessedBy': 'audit-user',
      'AccessReason': 'Audit review',
      'AccessHash': 'before:abc123',
      'AccessAfterHash': 'after:abc123'
    }
  ]
}
```

### Lambda: Maintain Chain of Custody

```python
def update_chain_of_custody(evidence_id, action, actor):
    """
    Update chain of custody when evidence is accessed
    SOC 2 Type II requirement: Who accessed what, when, and what did they see
    """
    table = dynamodb.Table('evidence-chain-of-custody')
    
    # Get current hash before access
    before_hash = calculate_hash(evidence_id)
    
    # Log access
    table.update_item(
        Key={'EvidenceID': evidence_id},
        UpdateExpression='SET #access = list_append(#access, :val)',
        ExpressionAttributeNames={'#access': 'Access'},
        ExpressionAttributeValues={
            ':val': [{
                'AccessTime': datetime.utcnow().isoformat(),
                'AccessedBy': actor,
                'AccessAction': action,
                'AccessHash': before_hash,
                'AccessAfterHash': calculate_hash(evidence_id)
            }]
        }
    )
```

### AWS Config Rules for Chain of Custody

```hcl
# DynamoDB point-in-time recovery (required for evidence recovery)
resource "aws_config_config_rule" "dynamodb_pitr" {
  name = "dynamodb-pitr-enabled"
  source {
    owner             = "AWS"
    source_identifier = "DYNAMODB_PITR_ENABLED"
  }
}

# S3 versioning for evidence immutability
resource "aws_config_config_rule" "s3_versioning" {
  name = "s3-bucket-versioning-enabled"
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
}

# CloudTrail logging for access audit
resource "aws_config_config_rule" "cloudtrail_enabled" {
  name = "cloudtrail-enabled"
  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }
}
```

---

## Deployment

```bash
cd lab-04-04-chain-of-custody/terraform
terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

---

## Verification

### Query Chain of Custody

```bash
aws dynamodb query --table-name evidence-chain-of-custody \
  --key-condition-expression "EvidenceID = :id" \
  --expression-attribute-values '{":id":{"S":"evidence-20260522-001"}}'
```

Expected: Returns complete history of who accessed evidence, when, and what they saw.

### Test Access Logging

```bash
# Download evidence and trigger access logging
aws s3 cp s3://evidence-archive/lab23-evidence/.../evidence.json ./

# Check DynamoDB for access record
aws dynamodb scan --table-name evidence-chain-of-custody
```

Expected: Access logged with timestamp, user, and before/after hashes.

---

## Success Criteria

- [ ] Chain of custody table created with all fields
- [ ] Access logging triggered on evidence retrieval
- [ ] Historical access records maintained
- [ ] Hashes calculated and verified
- [ ] Retention policy enforced
- [ ] Config rules detecting drift

---

## Interview Talking Points

**"How do you prove evidence hasn't been tampered with?"**
> "I use multiple mechanisms: (1) SHA-256 hash before and after every access, (2) S3 versioning so all versions are preserved, (3) DynamoDB audit trail showing exactly who accessed what and when, (4) KMS encryption so only authorized users can access evidence."

**"Can evidence be deleted?"**
> "No. S3 versioning prevents deletion. Every version is retained. The metadata in DynamoDB is also protected by PITR. If someone tries to delete evidence, all deleted versions can be recovered."

**"How long do you retain evidence?"**
> "7 years, per SOC 2 Type II requirements. The S3 lifecycle policy automatically moves evidence to Glacier after 30 days (cheaper), then permanently deletes after 7 years."

---

**Estimated Time:** 30 minutes  
**Difficulty:** Intermediate  

---

*Lab 4.4 created for CGE-P Certification*  
*Date: May 22, 2026*
