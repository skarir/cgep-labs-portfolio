# Lab 7.1: Capstone Project - Complete GRC Architecture

**CGE-P Certification Capstone** | Governance, Risk & Compliance | Multi-Cloud | NIST 800-53

---

## Overview

The **Capstone Project** integrates all 12 preceding labs into a unified, production-ready Governance, Risk, and Compliance (GRC) platform demonstrating:

- **Infrastructure as Code** (Terraform: AWS + GCP)
- **Policy as Code** (Rego: Conftest validation)
- **Evidence as Code** (Automated collection & verification)
- **Compliance as Code** (Continuous monitoring & scoring)
- **Standards as Code** (OSCAL documentation)

---

## Architecture: Complete GRC Platform

```
┌─────────────────────────────────────────────────────────────────┐
│                        GRC PLATFORM                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LAYER 1: INFRASTRUCTURE (Labs 2.3, 2.4, 5.2, 5.4)            │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  AWS: S3, DynamoDB, Lambda, KMS, CloudTrail, Config    │  │
│  │  GCP: Cloud Storage, Cloud KMS, Audit Logs, IAM        │  │
│  └─────────────────────────────────────────────────────────┘  │
│                            ↓                                    │
│  LAYER 2: EVIDENCE (Labs 2.5, 4.3, 4.4)                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Automated Collection → Validation → Chain of Custody   │  │
│  │  Evidence Archive (S3, Glacier) → Metadata (DynamoDB)   │  │
│  └─────────────────────────────────────────────────────────┘  │
│                            ↓                                    │
│  LAYER 3: POLICY (Labs 3.3, 3.4)                             │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Rego Policies → Conftest Validation → Pass/Fail        │  │
│  │  Automatic Remediation (Config Rules)                   │  │
│  └─────────────────────────────────────────────────────────┘  │
│                            ↓                                    │
│  LAYER 4: COMPLIANCE (Labs 4.3, 4.4, 6.1)                     │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Control Status Tracking → Compliance Scoring           │  │
│  │  OSCAL Documentation → Audit Reports                    │  │
│  └─────────────────────────────────────────────────────────┘  │
│                            ↓                                    │
│  LAYER 5: REPORTING & GOVERNANCE                              │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Dashboards → Executive Reports → Audit Submissions     │  │
│  │  Continuous Monitoring → Alerts → Remediation           │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## How the 12 Labs Integrate

### Foundational Labs (1-2)
- **Lab 1:** Password Policy Verification
- **Lab 2:** Inactive Key Rotation  
- **Labs 2.3:** First Compliant Resource (AWS S3) → **Foundation**

### Infrastructure Labs (2.4, 2.5, 5.2, 5.4)
- **Lab 2.4:** Terraform Modules (GCP)
- **Lab 2.5:** IaC Evidence Pipeline → **Collects evidence from 2.3**
- **Lab 5.2:** AWS Security Baseline
- **Lab 5.4:** GCP Security Baseline

### Policy & Validation Labs (3.3, 3.4)
- **Lab 3.3:** Rego Policies (GCP)
- **Lab 3.4:** Conftest Policy Validation → **Validates 2.3, 2.5**

### GRC & Evidence Labs (4.3, 4.4)
- **Lab 4.3:** Evidence Pipeline → **Integrates 2.3, 2.5, 3.4**
- **Lab 4.4:** Chain of Custody → **Tracks 2.5 evidence**

### Standards Lab (6.1)
- **Lab 6.1:** OSCAL → **Documents all 12 labs**

### Capstone Lab (7.1)
- **Lab 7.1:** Complete Integration → **You are here**

---

## Capstone Deliverables

### 1. Terraform Root Module

```hcl
# lab-07-01-capstone/terraform/main.tf

module "aws_s3_foundation" {
  source = "../lab-02-03-compliant-s3/terraform"
  # S3 buckets with 5 NIST controls
}

module "evidence_pipeline" {
  source = "../lab-02-05-iac-evidence/terraform"
  lab23_data_bucket_name = module.aws_s3_foundation.bucket_id
  # Evidence collection on top of S3
}

module "aws_baseline" {
  source = "../lab-05-02-aws-baseline/terraform"
  # Security baseline across 8 services
}

module "gcp_modules" {
  source = "../lab-02-04-terraform-modules/terraform"
  project_id = var.gcp_project_id
  # Reusable GCP modules
}

module "gcp_baseline" {
  source = "../lab-05-04-gcp-baseline/terraform"
  project_id = var.gcp_project_id
  # GCP security baseline
}

# Total: 50+ NIST 800-53 controls across AWS & GCP
```

### 2. Policy Suite

```bash
# lab-07-01-capstone/policies/

policies/
├── nist_sc28_encryption.rego       (SC-28: Encryption at rest)
├── nist_au3_logging.rego           (AU-3: Audit logging)
├── nist_ac3_access_control.rego    (AC-3: Access control)
├── nist_cm6_config_mgmt.rego       (CM-6: Configuration management)
├── nist_si10_integrity.rego        (SI-10: Evidence integrity)
├── nist_ca7_monitoring.rego        (CA-7: Continuous monitoring)
└── nist_ia2_authentication.rego    (IA-2: Authentication)

# Run: conftest test -p policies/ terraform.tfplan.json
```

### 3. GRC Dashboards

```bash
# CloudWatch dashboard showing:
# - Compliance Score (80%)
# - Controls Compliant: 50/50
# - Evidence Collected: 147 files
# - Policies Validated: 100% pass
# - Last Audit: Today
```

### 4. OSCAL Documentation

```bash
# lab-07-01-capstone/oscal/

oscal/
├── component-definitions/      (How each lab implements controls)
├── system-security-plans/      (Complete system architecture)
└── assessment-results/         (Compliance assessment)

# Run: oscal-cli convert ... --to html → audit-ready reports
```

---

## Deployment

### Step 1: Deploy Foundation (Lab 2.3)
```bash
cd lab-02-03-compliant-s3/terraform
terraform apply
```

### Step 2: Deploy Evidence Pipeline (Lab 2.5)
```bash
cd lab-02-05-iac-evidence/terraform
terraform apply
```

### Step 3: Deploy AWS Baseline (Lab 5.2)
```bash
cd lab-05-02-aws-baseline/terraform
terraform apply
```

### Step 4: Set Up GCP
```bash
cd lab-02-04-terraform-modules/terraform
gcloud auth login
gcloud config set project YOUR-PROJECT-ID
terraform apply
```

### Step 5: Deploy GCP Baseline (Lab 5.4)
```bash
cd lab-05-04-gcp-baseline/terraform
terraform apply
```

### Step 6: Run Policy Validation (Lab 3.4 & 3.3)
```bash
conftest test -p lab-03-04-conftest/policies/ terraform.tfplan.json
conftest test -p lab-03-03-rego-policies/policies/ gcp-plan.json
```

### Step 7: Run Full GRC Assessment (Capstone)
```bash
cd lab-07-01-capstone
./deploy.sh

# Generates:
# - Compliance score
# - Control status report
# - OSCAL documentation
# - Audit-ready reports
```

---

## Verification Checklist

- [ ] Lab 2.3 S3 buckets deployed (5 controls)
- [ ] Lab 2.5 evidence collection running (4 controls)
- [ ] Lab 5.2 AWS baseline deployed (8 controls)
- [ ] Lab 5.4 GCP baseline deployed (5 controls)
- [ ] Lab 3.4 Conftest policies passing (5 policies)
- [ ] Lab 3.3 GCP Rego policies passing (3 policies)
- [ ] Lab 4.3 GRC pipeline operational (6 Lambda functions)
- [ ] Lab 4.4 Chain of custody logged (100% access tracking)
- [ ] Lab 6.1 OSCAL documents validated
- [ ] Compliance score ≥ 85%
- [ ] All reports generated successfully

---

## Success Criteria

```bash
# 1. Infrastructure deployed across AWS & GCP
terraform show | grep "Resources:" | grep "1[0-9][0-9]"

# 2. Policies passing
conftest test -p policies/ *.tfplan.json | grep "passed"

# 3. Evidence collected
aws s3 ls s3://cgep-evidence-archive/ --recursive | wc -l

# 4. Compliance score calculated
aws dynamodb get-item --table-name grc-control-status \
  --key '{"ControlID":{"S":"OVERALL"}}' | grep ComplianceScore

# 5. OSCAL documents valid
oscal-cli validate system-security-plan oscal/ssp.json
```

---

## Interview Talking Points

**"Walk me through your compliance architecture"**
> "I have a complete GRC platform built on infrastructure-as-code. At the foundation (Lab 2.3) is compliant infrastructure - every S3 bucket is encrypted, versioned, and logged by default. Lab 2.5 automatically collects evidence daily. Lab 3.4 validates all configurations against NIST policies using Conftest. Lab 4.3 calculates a continuous compliance score. The entire system is documented in OSCAL for auditors. Every decision is traceable from control back to code."

**"What if a control fails?"**
> "The system detects it immediately - CloudWatch alerts the team, DynamoDB records it, Config rules can auto-remediate, and the compliance score updates. It's not just detection - it's prevention (policy validation before deployment) and remediation (automated fixes)."

**"How much manual work is compliance?"**
> "Zero. Everything runs automatically. Evidence is collected daily, policies are validated on every commit, the compliance score updates continuously. Auditors get real-time dashboards instead of stale paperwork."

**"Can you scale this to 1000 resources?"**
> "Yes. The architecture uses serverless components (Lambda, DynamoDB) that scale automatically. I've tested with 10x more resources - same cost, same architecture. The policies and evidence collection scale linearly."

---

## Timeline

| Phase | Labs | Time |
|-------|------|------|
| Foundation | 1-2, 2.3 | 1 hour |
| Evidence | 2.5, 4.3, 4.4 | 2 hours |
| Policy | 3.3, 3.4 | 1 hour |
| Infrastructure | 5.2, 5.4 | 2 hours |
| Standards | 6.1 | 0.5 hours |
| Integration | 7.1 | 1 hour |
| **TOTAL** | **12 labs** | **~7-8 hours** |

---

## Cost Summary

| Component | Monthly | Notes |
|-----------|---------|-------|
| S3 storage | $0.02 | Evidence archive |
| DynamoDB | $0.05 | Control status |
| Lambda | $0.01 | Evidence collection |
| KMS | $1.00 | Key operations |
| CloudTrail | $2.00 | Audit logging |
| Config | $2.00 | Continuous monitoring |
| **TOTAL** | **~$5/month** | Production-grade GRC |

---

## Next Steps

1. **Deploy Capstone** → Get compliance score
2. **Share with Security Team** → Review dashboards
3. **Submit to Audit** → Use OSCAL reports
4. **Extend Policies** → Add org-specific controls
5. **Continuous Improvement** → Monitor compliance trends

---

**Estimated Time:** 6-8 hours (full implementation)  
**Difficulty:** Expert  
**Cost:** ~$5/month AWS + GCP free tier  

---

## Success: Complete GRC Platform

You've built:
- ✅ **Infrastructure-as-Code** (AWS + GCP, 50+ controls)
- ✅ **Policy-as-Code** (Rego/Conftest validation)
- ✅ **Evidence-as-Code** (Automated collection)
- ✅ **Compliance-as-Code** (Continuous scoring)
- ✅ **Standards-as-Code** (OSCAL documentation)
- ✅ **Audit-Ready System** (Zero manual work)

This is **production-grade GRC**, ready for enterprise audits.

---

*Lab 7.1 Capstone created for CGE-P Certification*  
*Date: May 22, 2026*  
*Status: Complete GRC Platform - Ready for Deployment*
