# Lab 2.5: IaC as Compliance Evidence

**CGE-P Certification Lab** | Infrastructure as Code Evidence Pipeline | NIST 800-53 Compliance

---

## Overview

Lab 2.5 builds on Lab 2.3's S3 infrastructure to create an **automated evidence collection and storage pipeline**. Instead of manually capturing compliance evidence, this lab demonstrates how to implement infrastructure that continuously collects, archives, and verifies compliance evidence as code.

**Key Concept:** "Evidence-by-default" means your infrastructure automatically captures and stores compliance evidence throughout its lifecycle, not as an afterthought during audits.

---

## Learning Objectives

By completing this lab, you will:

✅ Build an automated evidence collection pipeline  
✅ Implement encrypted evidence storage with integrity verification  
✅ Create DynamoDB tables for evidence metadata tracking  
✅ Deploy Lambda functions for scheduled evidence collection  
✅ Understand evidence retention and chain-of-custody in IaC  
✅ Implement SI-10 evidence integrity controls  
✅ Generate compliance evidence from infrastructure

---

## NIST 800-53 Controls Implemented

### SC-28(1) - Encryption at Rest
**Control Requirement:** Protect information at rest using cryptographic mechanisms  
**Implementation:** KMS encryption for DynamoDB, S3 bucket, and logs  
**Evidence:** Terraform state shows encryption configuration  

### AU-3 - Recording of Information System Activities
**Control Requirement:** Record evidence collection activities  
**Implementation:** CloudWatch logs with KMS encryption, Lambda function logs  
**Evidence:** CloudWatch log group captures all collection activities  

### AU-6 - Review and Analysis of Audit Logs
**Control Requirement:** Review and analyze system activities  
**Implementation:** SNS notifications, scheduled CloudWatch Events  
**Evidence:** Automated review triggered by evidence collection  

### SI-10 - Evidence Integrity and Availability
**Control Requirement:** Maintain evidence integrity and completeness  
**Implementation:** Hash verification, DynamoDB PITR, S3 versioning, lifecycle policies  
**Evidence:** Lambda verification function, retention policies  

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Lab 2.3 S3 Bucket                        │
│         (Source of Evidence - Deployed Infrastructure)      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │   CloudWatch Events Rule      │
        │  (Daily at 2 AM UTC)          │
        │  Control: AU-6                │
        └────────────┬─────────────────┘
                     │
                     ▼
        ┌──────────────────────────────┐
        │  Lambda Evidence Collector    │
        │  • Collect bucket config      │
        │  • Archive to S3              │
        │  • Record metadata            │
        │  Control: AU-3                │
        └────────┬───────────┬──────────┘
                 │           │
      ┌──────────▼───┐   ┌───▼──────────┐
      │   Evidence    │   │  DynamoDB    │
      │   Archive S3  │   │  Metadata    │
      │ (Encrypted)   │   │  (Encrypted) │
      │ Control:      │   │  Control:    │
      │ SC-28(1)      │   │  SC-28(1)    │
      │ AU-3(1)       │   │  SI-10       │
      └──────────────┘   └──────────────┘
             │                   │
             └───────┬───────────┘
                     ▼
        ┌──────────────────────────────┐
        │   Evidence Verifier Lambda    │
        │  • Hash verification         │
        │  • Completeness check        │
        │  • Integrity assessment      │
        │  Control: SI-10              │
        └──────────────────────────────┘
```

---

## Prerequisites

- [ ] Lab 2.3 deployed (S3 buckets with configurations)
- [ ] AWS Account with Lambda, DynamoDB, KMS permissions
- [ ] Terraform 1.6 or higher
- [ ] Python 3.11 (for Lambda functions)
- [ ] 30-45 minutes of focused time

---

## Lab Setup

### Step 1: Navigate to Lab Directory

```bash
cd lab-02-05-iac-evidence/terraform
```

### Step 2: Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update:
- `lab23_data_bucket_name` - Your deployed Lab 2.3 bucket name

Example:
```hcl
lab23_data_bucket_name = "cgep-lab-data-sunil-20260522-191258"
lab_identifier         = "lab25-evidence"
```

### Step 3: Prepare Lambda Function Packages

The Terraform code references `lambda_function.zip` and `lambda_verify.zip`. Create these:

```bash
# From lambda directory
cd ../lambda

# Package evidence collector
zip -r ../terraform/lambda_function.zip index.py

# Package verifier
zip -r ../terraform/lambda_verify.zip verify.py

cd ../terraform
```

### Step 4: Initialize Terraform

```bash
terraform init
```

### Step 5: Validate Configuration

```bash
terraform validate
```

---

## Deployment

### Step 6: Plan the Deployment

```bash
terraform plan -out=plan.tfplan
```

**Expected resources:**
- DynamoDB table with GSI and encryption
- KMS encryption key with rotation enabled
- S3 evidence archive bucket with versioning and lifecycle policies
- 2 Lambda functions (collector + verifier)
- CloudWatch Events rule (daily schedule)
- CloudWatch log group with encryption
- SNS topic for notifications
- IAM roles and policies

**Total: ~15 resources**

### Step 7: Apply the Configuration

```bash
terraform apply plan.tfplan
```

### Step 8: Generate Compliance Evidence

```bash
mkdir -p ../evidence
terraform show -json plan.tfplan > ../evidence/plan.json
terraform show -json > ../evidence/state.json
```

---

## Verification

### Manual Verification

**1. Verify DynamoDB Encryption:**
```bash
aws dynamodb describe-table --table-name cgep-lab-evidence-metadata-lab25-evidence \
  --query 'Table.SSEDescription'
```

Expected output shows KMS encryption enabled.

**2. Verify S3 Evidence Archive:**
```bash
aws s3api get-bucket-encryption --bucket cgep-evidence-archive-lab25-evidence
```

Expected output shows KMS encryption configured.

**3. Verify Lambda Functions:**
```bash
aws lambda list-functions --query 'Functions[?contains(FunctionName, `evidence`)]' \
  --output table
```

Should show evidence-collector and evidence-verifier functions.

**4. Test Evidence Collection (Trigger Lambda):**
```bash
aws lambda invoke --function-name cgep-evidence-collector-lab25-evidence \
  --payload '{}' response.json

cat response.json
```

Expected: Success response with evidence ID and archive location.

**5. Verify Evidence was Archived:**
```bash
aws s3 ls s3://cgep-evidence-archive-lab25-evidence/lab23-evidence/

# Check metadata
aws s3api head-object \
  --bucket cgep-evidence-archive-lab25-evidence \
  --key lab23-evidence/2026-05-22/[evidence-id].json
```

---

## Key Concepts

### Evidence-by-Default
Your infrastructure automatically captures evidence. Auditors don't need to ask "show me your compliance" because the evidence already exists in an auditable, encrypted, versioned form.

### Evidence Integrity (SI-10)
- **Hash Verification**: Each evidence file is hashed using SHA-256. The hash is stored separately. The verifier Lambda can detect any tampering.
- **Versioning**: S3 versioning means every version of evidence is preserved. You cannot delete an old version.
- **PITR**: DynamoDB point-in-time recovery allows recovery to any point in the past 35 days.
- **Retention Policy**: Lifecycle policies archive to Glacier after 30 days and delete after 7 years (compliant with SOC 2/ISO 27001).

### Automated Collection
- **Scheduled**: CloudWatch Events triggers collection daily at 2 AM UTC (configurable).
- **Transparent**: Evidence collection doesn't require manual intervention or auditor involvement.
- **Immutable**: Once archived, evidence cannot be modified due to S3 versioning and legal hold (if enabled).

### Chain of Custody
DynamoDB metadata table tracks:
- Evidence ID
- Timestamp (collection date)
- Source (which S3 bucket)
- Control ID (which NIST controls this evidence supports)
- Archive location
- Hash (for integrity verification)
- Status (COLLECTED, VERIFIED, RETAINED)

An auditor can query the metadata table to understand the complete chain of custody.

---

## Interview Talking Points

**"How do you maintain evidence integrity?"**
> "I implement SI-10 controls through multiple layers: (1) KMS encryption at rest, (2) S3 versioning so evidence cannot be deleted, (3) SHA-256 hashing for integrity verification, (4) DynamoDB PITR for recovery, (5) Automated verification Lambda to detect tampering."

**"How do you prove continuous compliance?"**
> "Compliance evidence is collected automatically every day. An auditor can query the DynamoDB metadata table to see the complete chain of custody - who collected it, when, from where, and whether it was verified. No manual reporting needed."

**"What happens if someone tries to delete evidence?"**
> "They can't. S3 versioning prevents deletion. Even if they delete the current version, all prior versions are retained. The metadata table in DynamoDB with PITR can recover the deleted entry. And all attempts are logged in CloudWatch Logs."

**"How do you handle evidence retention?"**
> "Lifecycle policies manage retention automatically. Recent evidence stays in S3 (hot storage). After 30 days it moves to Glacier (cold storage). After 7 years it expires and is permanently deleted. This is compliant with SOC 2/ISO 27001 retention requirements."

---

## Troubleshooting

### "Lambda function not found"
**Solution:** Ensure lambda_function.zip and lambda_verify.zip exist in terraform directory:
```bash
ls -la terraform/lambda*.zip
```

### "DynamoDB table creation fails - encryption error"
**Solution:** Ensure KMS key was created successfully:
```bash
aws kms describe-key --key-id alias/cgep-lab-evidence-lab25-evidence
```

### "Evidence not appearing in S3"
**Solution:** Check Lambda logs:
```bash
aws logs tail /aws/lambda/cgep-evidence-collector-lab25-evidence --follow
```

### "DynamoDB query returns empty"
**Solution:** Manually trigger the Lambda to generate evidence:
```bash
aws lambda invoke --function-name cgep-evidence-collector-lab25-evidence \
  --payload '{}' response.json
```

---

## Connection to Capstone

Lab 2.5 creates the evidence collection infrastructure that will be:
- **Referenced in Lab 4.3** (Evidence Pipeline) for GRC integration
- **Used in Lab 7.1** (Capstone) as the evidence source for the complete compliance assessment
- **Extended in Lab 4.4** to add chain-of-custody tracking

---

## Success Criteria

All four success criteria must be met:

### ✅ Criterion 1: DynamoDB Encryption Configured
```bash
aws dynamodb describe-table --table-name cgep-lab-evidence-metadata-lab25-evidence \
  | grep -q "arn:aws:kms" && echo "PASS" || echo "FAIL"
```

### ✅ Criterion 2: Evidence Archive S3 Bucket Created
```bash
aws s3api head-bucket --bucket cgep-evidence-archive-lab25-evidence \
  && echo "PASS" || echo "FAIL"
```

### ✅ Criterion 3: Lambda Functions Deployed
```bash
aws lambda get-function --function-name cgep-evidence-collector-lab25-evidence \
  && echo "PASS" || echo "FAIL"
```

### ✅ Criterion 4: Evidence Successfully Collected
```bash
aws lambda invoke --function-name cgep-evidence-collector-lab25-evidence \
  --payload '{}' response.json && grep -q "statusCode.*200" response.json && echo "PASS" || echo "FAIL"
```

---

## Cleanup

To remove Lab 2.5 infrastructure:

```bash
terraform destroy
```

**Cost Impact:** Lab 2.5 uses on-demand pricing for DynamoDB (~$0.01/million operations) and Lambda (~$0.02 per million invocations). Total monthly cost is typically <$0.10.

---

## Lab Summary

**What You Built:**
- Automated evidence collection infrastructure
- Encrypted evidence storage with integrity verification
- DynamoDB metadata tracking with PITR
- Lambda-based evidence processor and verifier
- Scheduled evidence collection at scale
- 7-year evidence retention policy

**Skills Demonstrated:**
- Advanced Terraform (Lambda, DynamoDB, KMS, CloudWatch Events)
- Evidence management in infrastructure
- NIST SI-10 (Evidence Integrity) implementation
- Chain-of-custody tracking
- Automated compliance evidence collection

**Portfolio Value:**
This lab demonstrates that you understand:
- How to automate compliance evidence collection
- Evidence integrity and chain of custody
- Retention policies for regulatory compliance
- Automated audit trails

---

## Next Lab

**Lab 3.4: Conftest Policy Validation** validates that Lab 2.5's collected evidence meets compliance requirements through policy-as-code.

---

**Estimated Time:** 30-45 minutes  
**Difficulty:** Advanced  
**AWS Cost:** <$0.10 per month (on-demand pricing)  

**Ready to deploy?** Run `terraform init` in the terraform directory!

---

*Lab 2.5 created for CGE-P Certification*  
*Created by: Sunil Karir*  
*Date: May 22, 2026*
