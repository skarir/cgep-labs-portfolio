# Lab 3.3: Rego Policies for GCP

**CGE-P Certification Lab** | Policy as Code | GCP Compliance Validation

---

## Overview

Lab 3.3 extends Lab 3.4's Conftest approach to GCP, writing Rego policies that validate Google Cloud infrastructure for NIST 800-53 compliance.

---

## Policies

### Storage Bucket Encryption
```rego
deny[msg] {
    bucket := input.resource_changes[_]
    bucket.type == "google_storage_bucket"
    config := bucket.change.after
    not config.encryption[0].default_kms_key_name
    msg := sprintf("SC-28: Bucket %s missing KMS encryption", [bucket.address])
}
```

### IAM Service Account Restrictions
```rego
deny[msg] {
    role := input.resource_changes[_]
    role.type == "google_project_iam_member"
    role.change.after.role == "roles/owner"
    msg := sprintf("AC-6: Owner role assigned to %s (violation of least privilege)", 
                   [role.change.after.member])
}
```

---

## Deployment

```bash
cd lab-03-03-rego-policies

conftest test -p policies/ terraform.tfplan.json
```

Expected: All GCP infrastructure compliant with policies.

---

**Estimated Time:** 20-30 minutes  
**Difficulty:** Intermediate  
**Cost:** Free (Conftest)  

---

*Lab 3.3 created for CGE-P Certification*  
*Date: May 22, 2026*
