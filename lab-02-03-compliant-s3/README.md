# Lab 2.3: Building Your First Compliant Resource (AWS S3)

**CGE-P Certification Lab** | Infrastructure as Code | NIST 800-53 Compliance

---

## Overview

This lab teaches you how to express NIST 800-53 controls as Terraform infrastructure code. Instead of manually documenting compliance, you'll build AWS resources that **are compliant by default** through their configuration.

**Key Concept:** "Compliance-by-default" means security controls are baked into the infrastructure code itself, not added as an afterthought.

---

## Learning Objectives

By completing this lab, you will:

✅ Express NIST 800-53 controls as Terraform resources  
✅ Capture compliance evidence in JSON format  
✅ Create a reusable primitive (S3 bucket) for subsequent labs  
✅ Understand how IaC enables compliance automation  
✅ Generate Terraform plans as compliance evidence  

---

## NIST 800-53 Controls Implemented

### SC-28(1) - Encryption at Rest
**Control Requirement:** Protect information at rest using cryptographic mechanisms  
**Implementation:** S3 bucket with AES256 server-side encryption  
**Terraform Resource:** `aws_s3_bucket_server_side_encryption_configuration`  

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "compliant_encryption" {
  bucket = aws_s3_bucket.compliant_data_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

**Evidence:** Terraform show/state will confirm encryption algorithm and bucket key settings

---

### AU-3(1) & AU-6(1) - Audit Logging
**Control Requirement:** Record and review information system activities  
**Implementation:** Enable S3 access logging to separate logging bucket  
**Terraform Resource:** `aws_s3_bucket_logging`  

```hcl
resource "aws_s3_bucket_logging" "compliant_logging" {
  bucket = aws_s3_bucket.compliant_data_bucket.id
  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "access-logs/"
}
```

**Evidence:** Terraform state shows logging bucket target and prefix  
**Audit Trail:** All S3 access logs written to separate bucket for analysis

---

### CM-6(1) - Configuration Management
**Control Requirement:** Establish and maintain baseline configurations  
**Implementation:** Enable S3 versioning to maintain configuration history  
**Terraform Resource:** `aws_s3_bucket_versioning`  

```hcl
resource "aws_s3_bucket_versioning" "compliant_versioning" {
  bucket = aws_s3_bucket.compliant_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

**Evidence:** Terraform state confirms versioning enabled  
**Baseline:** Every object version is tracked, providing audit trail of changes

---

### AC-3(1) - Access Control
**Control Requirement:** Enforce access restrictions based on least privilege principle  
**Implementation:** Block all public access + enforce SSL/TLS connections  
**Terraform Resources:**
- `aws_s3_bucket_public_access_block`
- `aws_s3_bucket_acl`
- `aws_s3_bucket_policy` (SSL enforcement)

```hcl
resource "aws_s3_bucket_public_access_block" "compliant_public_block" {
  bucket = aws_s3_bucket.compliant_data_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

**Evidence:** Terraform state shows all public access blocks enabled  
**Least Privilege:** No public access possible, only authorized identities can interact

---

## Prerequisites

- [ ] AWS Account (with S3 creation permissions in us-east-1)
- [ ] Terraform 1.6 or higher
- [ ] AWS CLI v2 configured with credentials
- [ ] 30-45 minutes of focused time

**Check your setup:**
```bash
terraform version  # Should show v1.6+
aws sts get-caller-identity  # Should show your AWS account
```

---

## Lab Setup

### Step 1: Navigate to Lab Directory

```bash
cd lab-02-03-compliant-s3/terraform
```

### Step 2: Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update bucket names with your unique identifier:

```hcl
data_bucket_name    = "cgep-lab-compliant-data-YOUR-NAME-2026"
logging_bucket_name = "cgep-lab-logs-YOUR-NAME-2026"
```

**Important:** S3 bucket names must be **globally unique** across all AWS accounts

### Step 3: Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider plugin and prepares the directory.

### Step 4: Validate Configuration

```bash
terraform validate
```

This checks for syntax errors and logical inconsistencies.

---

## Deployment

### Step 5: Plan the Deployment

```bash
terraform plan -out=plan.tfplan
```

This shows what resources will be created. **Review carefully before applying.**

**Expected output:**
- 2 S3 buckets (data + logging)
- 5 bucket configurations (encryption, logging, versioning, ACL, policy)
- 1 public access block configuration (data bucket)
- 1 public access block configuration (logging bucket)

**Total: ~9 resources to be created**

### Step 6: Save Plan as Evidence

```bash
terraform show -json plan.tfplan > ../evidence/plan.json
```

This captures the Terraform plan in JSON format for compliance evidence.

### Step 7: Apply the Configuration

```bash
terraform apply plan.tfplan
```

This creates the S3 buckets and configurations in your AWS account.

**Cost:** <$0.01 if deleted same day (S3 storage is negligible for empty buckets)

### Step 8: Generate Compliance Evidence

```bash
# Save Terraform state as evidence
terraform show -json > ../evidence/state.json

# Also capture plain-text state for human review
terraform show > ../evidence/state.txt
```

---

## Verification

### Manual Verification (AWS CLI)

Verify each NIST control is correctly implemented:

**1. Verify Encryption (SC-28):**
```bash
aws s3api get-bucket-encryption \
  --bucket <data-bucket-name> \
  --region us-east-1
```

Expected output:
```json
{
  "ServerSideEncryptionConfiguration": {
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        },
        "BucketKeyEnabled": true
      }
    ]
  }
}
```

**2. Verify Logging (AU-3/AU-6):**
```bash
aws s3api get-bucket-logging \
  --bucket <data-bucket-name> \
  --region us-east-1
```

Expected output shows logging bucket target configured.

**3. Verify Versioning (CM-6):**
```bash
aws s3api get-bucket-versioning \
  --bucket <data-bucket-name> \
  --region us-east-1
```

Expected output:
```json
{
  "Status": "Enabled"
}
```

**4. Verify Access Control (AC-3):**
```bash
aws s3api get-public-access-block \
  --bucket <data-bucket-name> \
  --region us-east-1
```

Expected output shows all blocks set to `true`.

---

## Compliance Evidence

### What Constitutes Evidence

✅ **Terraform Plan (plan.json)** - Shows infrastructure configuration intended  
✅ **Terraform State (state.json)** - Shows actual deployed configuration  
✅ **AWS CLI Output** - Verification of settings in deployed environment  
✅ **This README** - Documentation of control mappings  

### How Auditors Use This Evidence

An auditor reviewing SC-28 compliance would:

1. Request: "Show me how you ensure encryption at rest for sensitive data"
2. You provide: `evidence/state.json` containing encryption configuration
3. Auditor verifies: SSE algorithm is AES256 ✓
4. Auditor checks: Bucket key is enabled for performance ✓
5. Result: **COMPLIANT** with SC-28(1)

---

## Success Criteria

All four success criteria must be met:

### ✅ Criterion 1: Encryption Configured
```bash
aws s3api get-bucket-encryption --bucket <name> --region us-east-1 \
  | grep -q "AES256" && echo "PASS" || echo "FAIL"
```

### ✅ Criterion 2: Versioning Enabled
```bash
aws s3api get-bucket-versioning --bucket <name> --region us-east-1 \
  | grep -q "Enabled" && echo "PASS" || echo "FAIL"
```

### ✅ Criterion 3: All Public Access Blocks Set
```bash
aws s3api get-public-access-block --bucket <name> --region us-east-1 \
  | grep -c "true" | grep -q 4 && echo "PASS" || echo "FAIL"
```

### ✅ Criterion 4: Evidence Files Generated
```bash
[ -f ../evidence/plan.json ] && [ -f ../evidence/state.json ] \
  && echo "PASS" || echo "FAIL"
```

---

## Cleanup

To avoid ongoing costs, destroy the resources:

```bash
terraform destroy
```

Confirm deletion when prompted. This removes both S3 buckets and all configurations.

**Cost Impact:** No charges for destroyed resources

---

## Key Concepts

### IaC as Compliance Evidence
Traditional compliance: "Here's a screenshot showing encryption is enabled"  
IaC Compliance: "Here's the code that implements encryption, the deployment plan, and the resulting state"

**Why IaC is better:**
- Auditable: Git history shows who changed what and when
- Reproducible: Same code = same compliance state
- Testable: Policy as Code can automatically verify
- Scalable: One compliance primitive reused across infrastructure

### Compliance-by-Default
Instead of "enable encryption as an afterthought," your infrastructure code has encryption baked in from day one. It's impossible to deploy an S3 bucket **without** encryption.

### Evidence Generation
The `terraform show -json` commands generate JSON evidence that can be:
- Parsed by compliance tools
- Stored in evidence management systems
- Compared against baselines
- Included in audit reports

---

## Connection to Capstone

This lab creates the foundational S3 primitive that will be:
- **Reused in Lab 2.5** (IaC as Evidence) for evidence collection
- **Referenced in Lab 4.3** (Evidence Pipeline) for automated assessment
- **Integrated in Lab 7.1** (Capstone) as part of the complete architecture

---

## Interview Talking Points

**"How do you implement compliance in infrastructure?"**
> "I express controls as code using Terraform. For example, SC-28 encryption at rest is implemented with the `aws_s3_bucket_server_side_encryption_configuration` resource. The Terraform plan becomes compliance evidence. This ensures every S3 bucket deployed is compliant by default."

**"How do you prove compliance to an auditor?"**
> "Instead of screenshots, I show the Terraform state and plans. The state.json file proves the exact configuration in production. The plan.json shows what will be deployed before it is. This is auditable, reproducible, and testable."

**"What's the advantage of IaC over manual configuration?"**
> "Three advantages: (1) Auditability - Git history shows every change, (2) Consistency - same code = same configuration everywhere, (3) Compliance - controls are enforced before deployment, not after."

---

## Troubleshooting

### Error: "Bucket already exists"
**Solution:** S3 bucket names are globally unique. Choose a different name in terraform.tfvars

### Error: "InvalidACL" when applying
**Solution:** Ensure public access block is applied before bucket ACL. The code has proper `depends_on` to handle this.

### Error: "Access Denied" when validating encryption
**Solution:** Ensure AWS CLI credentials are configured and have s3:GetBucketEncryption permission

### Plan shows no changes but terraform apply fails
**Solution:** Run `terraform plan -out=plan.tfplan` again and apply that specific plan file

---

## Lab Summary

**What You Built:**
- An S3 bucket configured with 5 NIST 800-53 controls
- Audit-ready Terraform code expressing compliance requirements
- JSON evidence files suitable for compliance audits
- A reusable primitive for subsequent labs

**Skills Demonstrated:**
- Terraform fundamentals (providers, resources, variables, outputs)
- NIST 800-53 control mapping
- AWS S3 configuration for compliance
- Evidence generation and documentation
- AWS CLI verification of configurations

**Portfolio Value:**
This lab demonstrates that you understand how to:
- Express compliance requirements in code
- Generate auditable evidence automatically
- Create compliant infrastructure by default
- Document control mappings for auditors

---

## Next Lab

**Lab 2.5: IaC as Compliance Evidence** builds on this foundation by:
- Creating a pipeline to automatically collect evidence
- Storing evidence in a chain-of-custody format
- Integrating multiple resources into a compliance report
- Preparing data for Lab 4.3 (GRC Evidence Pipeline)

---

**Estimated Time:** 30-45 minutes  
**Difficulty:** Intermediate  
**AWS Cost:** <$0.01 (if deleted same day)  

**Ready to start?** Run `terraform init` in the terraform directory!

---

*Lab 2.3 created for CGE-P Certification*  
*Created by: Sunil Karir*  
*Date: May 22, 2026*
