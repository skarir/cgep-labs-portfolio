# Lab 2.4: Terraform Modules for GCP

**CGE-P Certification Lab** | Infrastructure as Code | GCP Security Controls

---

## Overview

Lab 2.4 creates **reusable Terraform modules for GCP** that implement NIST 800-53 controls. This demonstrates how modules enable consistent security across environments (AWS in Lab 2.3, GCP here).

---

## Controls Implemented

| Control | GCP Service | Implementation |
|---------|-------------|-----------------|
| SC-28(1) | Cloud Storage | Encryption at rest |
| AU-3(1) | Cloud Logging | Access logging |
| AC-3(1) | IAM | Service account RBAC |
| CM-6(1) | Versioning | Object versioning |

---

## Module Structure

```
modules/
├── cloud_storage/
│   ├── main.tf          (Bucket + encryption + versioning)
│   ├── variables.tf     (Input variables)
│   ├── outputs.tf       (Outputs for audit)
│   └── README.md        (Module documentation)
├── iam/
│   ├── main.tf          (Service accounts + roles)
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── logging/
    ├── main.tf          (Cloud Logging + sinks)
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

---

## Key Module: Cloud Storage

```hcl
module "secure_bucket" {
  source = "./modules/cloud_storage"
  
  project_id       = var.project_id
  bucket_name      = "cgep-lab-gcp-${var.environment}"
  location         = "US"
  encryption_key   = google_kms_crypto_key.bucket_key.id
  
  enable_versioning = true
  enable_logging    = true
  
  lifecycle_rules = [{
    action = "Delete"
    num_newer_versions = 7
  }]
}
```

---

## Deployment

```bash
cd lab-02-04-terraform-modules/terraform

# Set GCP project
export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value project)

terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

---

## Prerequisites

- [ ] GCP project created
- [ ] gcloud CLI configured
- [ ] Terraform 1.6+
- [ ] Service account with Editor role

---

**Estimated Time:** 30-40 minutes  
**Difficulty:** Intermediate  
**GCP Cost:** Free tier (~$0.05/month for storage)  

---

*Lab 2.4 created for CGE-P Certification*  
*Date: May 22, 2026*
