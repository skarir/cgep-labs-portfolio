# CGE-P Labs: Complete Deployment Guide

**All 12 Labs Ready for Deployment**  
**Date:** May 22, 2026  
**Status:** ✅ Lab 2.3 Deployed | Labs 2.5-7.1 Ready  

---

## Quick Summary

| Lab | Topic | Status | Time | Cloud |
|-----|-------|--------|------|-------|
| 1 | Password Policy Verification | ✅ Complete | 0.5h | N/A |
| 2 | Inactive Key Rotation | ✅ Complete | 0.5h | N/A |
| **2.3** | **First Compliant Resource (S3)** | **✅ DEPLOYED** | **0.5h** | **AWS** |
| 2.4 | Terraform Modules | 📋 Ready | 0.5h | GCP |
| 2.5 | IaC Evidence Pipeline | 📋 Ready | 0.75h | AWS |
| 3.3 | Rego Policies (GCP) | 📋 Ready | 0.5h | GCP |
| 3.4 | Conftest Policy Validation | 📋 Ready | 0.5h | N/A |
| 4.3 | Evidence Pipeline | 📋 Ready | 0.75h | AWS |
| 4.4 | Chain of Custody | 📋 Ready | 0.5h | AWS |
| 5.2 | AWS Security Baseline | 📋 Ready | 1h | AWS |
| 5.4 | GCP Security Baseline | 📋 Ready | 1h | GCP |
| 6.1 | OSCAL Documentation | 📋 Ready | 0.5h | N/A |
| 7.1 | Capstone Integration | 📋 Ready | 1h | AWS+GCP |
| | **TOTAL** | | **~8 hours** | |

---

## Deployment Phases

### Phase 1: AWS Foundation (1.5 hours)

```bash
# Deploy Lab 2.3 (Already done ✅)
cd lab-02-03-compliant-s3/terraform
terraform apply  # DEPLOYED

# Deploy Lab 2.5 (Evidence Pipeline)
cd lab-02-05-iac-evidence/terraform
cp terraform.tfvars.example terraform.tfvars
# Update: lab23_data_bucket_name = "cgep-lab-data-sunil-20260522-191258"
terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

**Verification:**
```bash
# Check evidence collection
aws lambda invoke --function-name cgep-evidence-collector-lab25-evidence \
  --payload '{}' response.json
```

---

### Phase 2: Policy Validation (1 hour)

```bash
# Lab 3.4: Conftest (Policy-as-Code)
cd lab-03-04-conftest

# Install Conftest if not already installed
brew install conftest  # or your OS equivalent

# Validate Lab 2.3 plan
conftest test -p policies/ ../lab-02-03-compliant-s3/evidence/plan.json -v

# Expected: All controls PASS
```

---

### Phase 3: AWS Baseline (1 hour)

```bash
# Lab 5.2: AWS Security Baseline
cd lab-05-02-aws-baseline/terraform
cp terraform.tfvars.example terraform.tfvars

terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan

# Verification
aws cloudtrail describe-trails | grep IsMultiRegionTrail
aws configservice describe-config-rules | wc -l
aws guardduty list-detectors
```

---

### Phase 4: GCP Setup (15 minutes)

```bash
# Create GCP project
gcloud projects create cgep-labs-gcp --set-as-default

# Enable APIs
gcloud services enable storage-api.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable logging.googleapis.com

# Create service account for Terraform
gcloud iam service-accounts create cgep-terraform \
  --display-name="CGEP Terraform"

# Grant permissions
gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
  --member=serviceAccount:cgep-terraform@$(gcloud config get-value project).iam.gserviceaccount.com \
  --role=roles/editor

# Create key
gcloud iam service-accounts keys create ~/cgep-terraform-key.json \
  --iam-account=cgep-terraform@$(gcloud config get-value project).iam.gserviceaccount.com

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS=~/cgep-terraform-key.json
```

---

### Phase 5: GCP Infrastructure (2.5 hours)

```bash
# Lab 2.4: Terraform Modules
cd lab-02-04-terraform-modules/terraform
cp terraform.tfvars.example terraform.tfvars
# Update: project_id = "cgep-labs-gcp"

terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan

# Lab 3.3: Rego Policies (GCP)
cd lab-03-03-rego-policies
conftest test -p policies/ ../lab-02-04-terraform-modules/evidence/plan.json

# Lab 5.4: GCP Security Baseline
cd lab-05-04-gcp-baseline/terraform
terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

---

### Phase 6: GRC Integration (1.5 hours)

```bash
# Lab 4.3: Evidence Pipeline
cd lab-04-03-evidence-pipeline
# Configure and deploy evidence pipeline Lambda/DynamoDB

# Lab 4.4: Chain of Custody
cd lab-04-04-chain-of-custody/terraform
terraform init
terraform apply

# Verify chain of custody
aws dynamodb scan --table-name evidence-chain-of-custody
```

---

### Phase 7: Standards & Capstone (1.5 hours)

```bash
# Lab 6.1: OSCAL Documentation
cd lab-06-01-oscal
oscal-cli validate component component-definitions/*.json
oscal-cli validate system-security-plan system-security-plans/*.json

# Lab 7.1: Capstone Integration
cd lab-07-01-capstone
./deploy.sh

# Generate final reports
./generate-audit-report.sh
```

---

## Prerequisites Checklist

### AWS
- [ ] AWS Account with credentials configured
- [ ] AWS CLI v2 installed
- [ ] Terraform 1.6+ installed ✅
- [ ] Appropriate IAM permissions (EC2, S3, Lambda, DynamoDB, KMS, CloudTrail, Config, GuardDuty)

### GCP
- [ ] GCP Account with billing enabled
- [ ] gcloud CLI installed
- [ ] Service account created with Editor role
- [ ] GOOGLE_APPLICATION_CREDENTIALS set

### Tools
- [ ] Conftest installed (for policy validation)
- [ ] OSCAL CLI installed (for standards documentation)
- [ ] jq installed (for JSON processing)

---

## Verification Commands

### AWS Foundation
```bash
# Lab 2.3: S3 Buckets
aws s3 ls | grep cgep-lab-data

# Lab 2.5: Evidence Collection
aws lambda list-functions | grep evidence-collector

# Lab 5.2: Security Baseline
aws cloudtrail describe-trails | grep cgep
aws guardduty list-detectors
```

### GCP Infrastructure
```bash
# Lab 2.4: Cloud Storage Buckets
gsutil ls | grep cgep-lab

# Lab 5.4: GCP Baseline
gcloud logging sinks list
gcloud kms keyrings list --location us
```

### Compliance Status
```bash
# Overall compliance score
aws dynamodb get-item --table-name grc-control-status \
  --key '{"ControlID":{"S":"OVERALL"}}'

# Control status
aws dynamodb scan --table-name grc-control-status \
  --projection-expression "ControlID, #s, ComplianceScore" \
  --expression-attribute-names '{"#s":"Status"}'
```

---

## Troubleshooting

### "Terraform not found"
```bash
export PATH="$HOME/.local/bin:$PATH"
terraform version
```

### "Service account permissions denied"
```bash
# Re-grant permissions
gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
  --member=serviceAccount:cgep-terraform@$(gcloud config get-value project).iam.gserviceaccount.com \
  --role=roles/editor
```

### "Lambda zip file not found"
```bash
# Create lambda packages
cd lab-02-05-iac-evidence/lambda
zip -r ../terraform/lambda_function.zip index.py
zip -r ../terraform/lambda_verify.zip verify.py
```

### "Conftest policy validation fails"
```bash
# Check policy syntax
conftest parse policies/nist_sc28_encryption.rego

# Verbose output
conftest test -p policies/ plan.json -v
```

---

## Cost Estimate

### Monthly Costs (All Labs Running)

| Service | Estimated Cost |
|---------|---|
| AWS S3 (storage + requests) | $0.05 |
| AWS Lambda | $0.02 |
| AWS DynamoDB | $0.10 |
| AWS KMS | $1.00 |
| AWS CloudTrail | $2.00 |
| AWS Config | $2.00 |
| AWS GuardDuty | $0.50 |
| **AWS Total** | **~$5.67/month** |
| GCP Cloud Storage | $0.02 |
| GCP Cloud KMS | $0.30 |
| GCP Cloud Logging | $0.10 |
| **GCP Total** | **~$0.42/month** |
| **TOTAL** | **~$6/month** |

**Free Tier:** Both AWS and GCP free tiers cover most of this - actual cost likely $0-2/month.

---

## Time Estimate

**With parallel deployment:**
- Phase 1 (AWS Foundation): 1.5 hours
- Phase 2 (Policy): 1 hour (can run during Phase 1)
- Phase 3 (AWS Baseline): 1 hour (parallel with Phase 2)
- Phase 4 (GCP Setup): 0.25 hours
- Phase 5 (GCP Labs): 2.5 hours (parallel with Phases 3)
- Phase 6 (GRC): 1.5 hours
- Phase 7 (Capstone): 1.5 hours
- **Total: ~5-6 hours** (with parallelization)

---

## Success Criteria (Final Checklist)

### Infrastructure Deployed
- [ ] Lab 2.3: 2 S3 buckets + 7 configurations
- [ ] Lab 2.5: DynamoDB + KMS + 2 Lambda functions
- [ ] Lab 5.2: CloudTrail + Config + GuardDuty + Secret Manager
- [ ] Lab 2.4: GCP buckets with Terraform modules
- [ ] Lab 5.4: Cloud Audit Logs + Cloud KMS + Cloud IAM

### Policies Validated
- [ ] Lab 3.4: 5 NIST controls passing Conftest
- [ ] Lab 3.3: GCP infrastructure compliant with Rego policies

### Evidence Collected
- [ ] Lab 2.5: Daily evidence collection running
- [ ] Lab 4.3: GRC pipeline processing evidence
- [ ] Lab 4.4: Chain of custody tracked in DynamoDB

### Compliance Reported
- [ ] Lab 6.1: OSCAL documents generated
- [ ] Lab 7.1: Compliance score calculated (target: ≥80%)
- [ ] Audit reports generated in HTML/PDF format

### Final Output
- [ ] Terraform code for all 12 labs in Git
- [ ] Evidence files in S3 archive (immutable)
- [ ] OSCAL documentation (auditor-ready)
- [ ] Compliance dashboard (real-time)
- [ ] Cost-optimized architecture (<$10/month)

---

## Next: Submit to Auditor

Once all labs are deployed:

```bash
# Generate audit package
./generate-audit-report.sh

# Files to submit:
# - oscal/system-security-plan.json
# - audit-reports/compliance-assessment.html
# - audit-reports/control-mapping.xlsx
# - README.md (this file)

# Auditor gets:
# - Complete infrastructure documentation
# - Evidence of all 50+ controls
# - Continuous compliance monitoring
# - Audit-ready OSCAL format
```

---

## Remember

✅ **Infrastructure-as-Code** means compliance is in code, not paper  
✅ **Policy-as-Code** means validation is automated, not manual  
✅ **Evidence-as-Code** means audit is real-time, not annual  
✅ **Compliance-as-Code** means you know your status 24/7  

---

**Status: Ready for Full Deployment**  
**Estimated Timeline: 5-6 hours**  
**Estimated Cost: ~$6/month**  

Ready? Start with Phase 1 above! 🚀

---

*CGE-P Labs Complete Deployment Guide*  
*All 12 Labs Documented & Ready*  
*May 22, 2026*
