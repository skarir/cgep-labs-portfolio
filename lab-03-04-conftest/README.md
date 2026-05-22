# Lab 3.4: Conftest Policy Validation

**CGE-P Certification Lab** | Policy as Code | NIST 800-53 Compliance Validation

---

## Overview

Lab 3.4 implements **Conftest** to automatically validate that your infrastructure (from Labs 2.3 & 2.5) complies with NIST 800-53 policies. Instead of manually reviewing configurations, Conftest automatically tests Terraform plans against compliance policies written in Rego.

**Key Concept:** "Policy-driven compliance" means your infrastructure is validated against policies before it's deployed, preventing non-compliant configurations from reaching production.

---

## Learning Objectives

By completing this lab, you will:

✅ Write Rego policies for NIST 800-53 controls  
✅ Validate Terraform plans with Conftest  
✅ Implement policy-as-code for compliance enforcement  
✅ Create CI/CD compliance gates  
✅ Understand control mapping in policies  
✅ Generate compliance reports from policy evaluation  

---

## Policy Rules Implemented

### SC-28: Encryption at Rest
```rego
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not has_encryption(resource)
    msg := sprintf("SC-28: S3 bucket must have encryption enabled: %s", [resource.address])
}
```

### AU-3: Audit Logging
```rego
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not has_logging(resource)
    msg := sprintf("AU-3: S3 bucket must have access logging: %s", [resource.address])
}
```

### AC-3: Access Control
```rego
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    not all_blocks_enabled(resource)
    msg := sprintf("AC-3: All public access blocks must be enabled: %s", [resource.address])
}
```

### CM-6: Configuration Management
```rego
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_versioning"
    not has_versioning(resource)
    msg := sprintf("CM-6: S3 bucket must have versioning enabled: %s", [resource.address])
}
```

---

## Prerequisites

- [ ] Conftest installed (version 0.40+)
- [ ] Terraform plan files from Labs 2.3, 2.5 (in JSON format)
- [ ] Text editor for Rego policies
- [ ] 15-20 minutes

---

## Lab Files

### Directory Structure

```
lab-03-04-conftest/
├── README.md                          (This file)
├── policies/
│   ├── nist_sc28_encryption.rego      (Encryption at rest)
│   ├── nist_au3_logging.rego          (Audit logging)
│   ├── nist_ac3_access_control.rego   (Access control)
│   ├── nist_cm6_config_mgmt.rego      (Configuration management)
│   └── nist_si10_integrity.rego       (Evidence integrity)
├── test-data/
│   ├── lab23-plan.json                (Lab 2.3 plan)
│   └── lab25-plan.json                (Lab 2.5 plan)
└── test-results/
    └── compliance-report.txt          (Generated after validation)
```

---

## Rego Policies

### 1. SC-28: Encryption Policy

```rego
# nist_sc28_encryption.rego
package terraform

import data.terraform.module as module

# Deny S3 buckets without encryption
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_server_side_encryption_configuration"
    config := resource.change.after
    config.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm != "AES256"
    msg := sprintf("SC-28 FAILED: S3 bucket encryption must be AES256, got: %v", 
                   [config.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm])
}

# Pass: Encryption properly configured
compliance[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_server_side_encryption_configuration"
    config := resource.change.after
    config.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm == "AES256"
    msg := sprintf("SC-28 PASSED: S3 bucket encryption configured with AES256")
}
```

### 2. AU-3: Logging Policy

```rego
# nist_au3_logging.rego
package terraform

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_logging"
    config := resource.change.after
    config.target_bucket == null
    msg := sprintf("AU-3 FAILED: S3 bucket logging not configured: %s", [resource.address])
}

compliance[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_logging"
    config := resource.change.after
    config.target_bucket != null
    msg := sprintf("AU-3 PASSED: S3 access logging configured to: %s", [config.target_bucket])
}
```

### 3. AC-3: Access Control Policy

```rego
# nist_ac3_access_control.rego
package terraform

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    config := resource.change.after
    config.block_public_acls != true
    msg := sprintf("AC-3 FAILED: block_public_acls must be true: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    config := resource.change.after
    config.block_public_policy != true
    msg := sprintf("AC-3 FAILED: block_public_policy must be true: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    config := resource.change.after
    config.ignore_public_acls != true
    msg := sprintf("AC-3 FAILED: ignore_public_acls must be true: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    config := resource.change.after
    config.restrict_public_buckets != true
    msg := sprintf("AC-3 FAILED: restrict_public_buckets must be true: %s", [resource.address])
}

compliance[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    config := resource.change.after
    config.block_public_acls == true
    config.block_public_policy == true
    config.ignore_public_acls == true
    config.restrict_public_buckets == true
    msg := sprintf("AC-3 PASSED: All public access blocks enabled for: %s", [resource.address])
}
```

### 4. CM-6: Configuration Management Policy

```rego
# nist_cm6_config_mgmt.rego
package terraform

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_versioning"
    config := resource.change.after
    config.versioning_configuration[0].status != "Enabled"
    msg := sprintf("CM-6 FAILED: Versioning must be enabled: %s", [resource.address])
}

compliance[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_versioning"
    config := resource.change.after
    config.versioning_configuration[0].status == "Enabled"
    msg := sprintf("CM-6 PASSED: Versioning enabled for: %s", [resource.address])
}
```

---

## Usage

### Step 1: Install Conftest

```bash
# macOS
brew install conftest

# Linux
wget https://github.com/open-policy-agent/conftest/releases/download/v0.50.0/conftest_0.50.0_Linux_x86_64.tar.gz
tar -xf conftest_0.50.0_Linux_x86_64.tar.gz
sudo mv conftest /usr/local/bin/

# Verify
conftest --version
```

### Step 2: Validate Lab 2.3 Plan

```bash
# Navigate to lab directory
cd lab-03-04-conftest

# Validate the Terraform plan
conftest test -p policies/ ../lab-02-03-compliant-s3/evidence/plan.json

# Or with detailed output
conftest test -p policies/ ../lab-02-03-compliant-s3/evidence/plan.json -v
```

### Step 3: Validate Lab 2.5 Plan

```bash
conftest test -p policies/ ../lab-02-05-iac-evidence/evidence/plan.json
```

### Step 4: Generate Compliance Report

```bash
# Combine test output with formatting
conftest test -p policies/ ../lab-02-03-compliant-s3/evidence/plan.json \
  -p policies/ ../lab-02-05-iac-evidence/evidence/plan.json \
  -o table > test-results/compliance-report.txt

cat test-results/compliance-report.txt
```

---

## Expected Output

### Passing Validation

```
PASS - SC-28 PASSED: S3 bucket encryption configured with AES256
PASS - AU-3 PASSED: S3 access logging configured to: cgep-lab-logs-sunil-20260522-191258
PASS - AC-3 PASSED: All public access blocks enabled for: aws_s3_bucket_public_access_block.compliant_public_block
PASS - CM-6 PASSED: Versioning enabled for: aws_s3_bucket_versioning.compliant_versioning

4 passed, 0 failed
```

### Failing Validation (Example)

```
FAIL - SC-28 FAILED: S3 bucket encryption must be AES256, got: aws:kms
FAIL - AU-3 FAILED: S3 bucket logging not configured

2 passed, 2 failed
```

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Compliance Validation

on: [pull_request]

jobs:
  conftest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install Conftest
        run: |
          wget https://github.com/open-policy-agent/conftest/releases/download/v0.50.0/conftest_0.50.0_Linux_x86_64.tar.gz
          tar -xf conftest_0.50.0_Linux_x86_64.tar.gz
          sudo mv conftest /usr/local/bin/
      
      - name: Terraform Plan
        run: |
          cd lab-02-03-compliant-s3/terraform
          terraform init
          terraform plan -out=plan.tfplan
          terraform show -json plan.tfplan > plan.json
      
      - name: Validate with Conftest
        run: |
          conftest test -p ../../lab-03-04-conftest/policies/ plan.json
```

---

## Success Criteria

All validations must pass:

### ✅ SC-28 Encryption Control
```bash
conftest test -p policies/ ../lab-02-03-compliant-s3/evidence/plan.json | grep "SC-28 PASSED"
```

### ✅ AU-3 Logging Control  
```bash
conftest test -p policies/ ../lab-02-03-compliant-s3/evidence/plan.json | grep "AU-3 PASSED"
```

### ✅ AC-3 Access Control
```bash
conftest test -p policies/ ../lab-02-03-compliant-s3/evidence/plan.json | grep "AC-3 PASSED"
```

### ✅ CM-6 Configuration Management
```bash
conftest test -p policies/ ../lab-02-03-compliant-s3/evidence/plan.json | grep "CM-6 PASSED"
```

---

## Interview Talking Points

**"How do you enforce compliance in code?"**
> "I use Conftest with Rego policies to validate Terraform plans against NIST 800-53 controls before they're applied. Any non-compliant configuration is rejected automatically. This prevents compliance violations from reaching production."

**"Can developers bypass your policies?"**
> "No. The policies are enforced in CI/CD pipelines. Every pull request must pass compliance validation before merging. This is infrastructure-as-code applied to compliance itself."

**"How do you maintain and update policies?"**
> "Policies are stored in Git, versioned, and reviewed like any code. When NIST changes or we discover a new compliance requirement, we update the Rego policy and all future plans are validated against it."

---

## Lab Summary

**What You Built:**
- Rego policies for 5 NIST 800-53 controls
- Automated validation of Terraform plans
- Compliance-as-code pipeline
- CI/CD integration points

**Skills Demonstrated:**
- Open Policy Agent (OPA) / Rego syntax
- Policy-driven compliance enforcement
- Terraform plan validation
- Compliance automation

---

## Next Lab

**Lab 4.3: Evidence Pipeline** integrates evidence collection with policy validation for end-to-end GRC automation.

---

**Estimated Time:** 15-20 minutes (once Conftest is installed)  
**Difficulty:** Intermediate  
**Cost:** Free (Conftest is open-source)  

---

*Lab 3.4 created for CGE-P Certification*  
*Date: May 22, 2026*
