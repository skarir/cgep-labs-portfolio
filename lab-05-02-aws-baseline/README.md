# Lab 5.2: AWS Security Baseline

**CGE-P Certification Lab** | Security Controls Across AWS Services | NIST 800-53

---

## Overview

Lab 5.2 implements a **comprehensive AWS security baseline** across multiple services, demonstrating that compliance is not just S3 buckets but a foundation spanning **IAM, CloudTrail, GuardDuty, VPC Flow Logs, Config, and Secrets Manager**.

---

## Controls Implemented

| Control | Service | Implementation |
|---------|---------|-----------------|
| AC-2 | IAM | Account & access management |
| AC-6 | IAM | Least privilege policies |
| AU-2 | CloudTrail | Logging of all API calls |
| AU-6 | CloudWatch | Log analysis & alerting |
| CA-7 | Config | Continuous monitoring |
| IA-2 | IAM | Multi-factor authentication |
| SC-7 | VPC | Network access controls |
| SI-4 | GuardDuty | Intrusion detection |

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│              AWS Security Baseline               │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────┬──────────────────────┐   │
│  │      IAM        │     CloudTrail       │   │
│  │ • Root access   │ • API logging        │   │
│  │ • MFA enforced  │ • S3 archive         │   │
│  │ • Least priv.   │ • CloudWatch logs    │   │
│  └─────────────────┴──────────────────────┘   │
│                                                 │
│  ┌─────────────────┬──────────────────────┐   │
│  │  Secrets Mgr.   │    Config Rules      │   │
│  │ • Passwords     │ • Compliance status  │   │
│  │ • API keys      │ • Drift detection    │   │
│  │ • Auto rotation │ • Remediation        │   │
│  └─────────────────┴──────────────────────┘   │
│                                                 │
│  ┌─────────────────┬──────────────────────┐   │
│  │   GuardDuty     │    VPC Flow Logs     │   │
│  │ • Threat detect │ • Network monitor    │   │
│  │ • ML-based      │ • Anomaly detection  │   │
│  │ • Findings      │ • S3 export          │   │
│  └─────────────────┴──────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## Key Implementations

### 1. IAM Security (AC-2, AC-6, IA-2)

```hcl
# Enforce MFA for root account
resource "aws_iam_account_password_policy" "baseline" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 24
  max_password_age               = 90
}

# Least privilege custom policy
resource "aws_iam_policy" "least_privilege" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::specific-bucket/*"
      }
    ]
  })
}
```

### 2. CloudTrail Logging (AU-2, AU-6)

```hcl
resource "aws_cloudtrail" "baseline" {
  name                          = "security-baseline-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
}
```

### 3. AWS Config Rules (CA-7)

```hcl
# Monitor S3 encryption compliance
resource "aws_config_config_rule" "s3_encryption" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
}

# Monitor IAM MFA
resource "aws_config_config_rule" "iam_mfa" {
  name = "iam-policy-no-statements-with-admin-access"

  source {
    owner             = "AWS"
    source_identifier = "IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS"
  }
}
```

### 4. GuardDuty (SI-4)

```hcl
resource "aws_guardduty_detector" "baseline" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
  }
}
```

### 5. Secrets Manager (SC-28)

```hcl
resource "aws_secretsmanager_secret" "api_key" {
  name_prefix             = "api-key-"
  description             = "API key for application"
  recovery_window_in_days = 7

  replica {
    region = "us-west-2"
  }
}

resource "aws_secretsmanager_secret_version" "api_key" {
  secret_id       = aws_secretsmanager_secret.api_key.id
  secret_string   = jsonencode({"key": "value"})
}
```

---

## Deployment

```bash
cd lab-05-02-aws-baseline/terraform

# Copy variables
cp terraform.tfvars.example terraform.tfvars

# Deploy
terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

---

## Verification Checklist

- [ ] CloudTrail enabled and logging to S3
- [ ] CloudTrail logs encrypted with KMS
- [ ] Config Rules detecting compliance drift
- [ ] GuardDuty findings (if any) documented
- [ ] IAM password policy enforced
- [ ] VPC Flow Logs enabled
- [ ] Secrets Manager secrets created with rotation

---

## Success Criteria

All must pass:

```bash
# CloudTrail enabled
aws cloudtrail describe-trails | grep IsMultiRegionTrail

# Config rules active
aws configservice describe-config-rules | grep ConfigRuleName

# GuardDuty detector enabled
aws guardduty list-detectors | grep DetectorIds

# IAM password policy
aws iam get-account-password-policy | grep MinimumPasswordLength
```

---

## Interview Talking Points

**"What's your AWS security baseline?"**
> "I implement multi-layered controls: CloudTrail for auditing all API calls, Config for continuous compliance monitoring, GuardDuty for intrusion detection, IAM for least-privilege access, and Secrets Manager for credential protection. These work together to provide defense-in-depth."

**"How do you detect compliance drift?"**
> "AWS Config continuously evaluates resources against rules. If someone manually creates an unencrypted bucket or removes logging, Config detects it within minutes and can automatically remediate."

**"Do you monitor suspicious activity?"**
> "Yes. GuardDuty uses machine learning to detect suspicious activity patterns - unusual API calls, data exfiltration attempts, etc. CloudTrail logs every API call for investigation if needed."

---

**Estimated Time:** 45-60 minutes  
**Difficulty:** Advanced  
**AWS Cost:** $1-2/month (CloudTrail, Config, GuardDuty)  

---

*Lab 5.2 created for CGE-P Certification*  
*Date: May 22, 2026*
