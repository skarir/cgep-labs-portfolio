# Lab 5.4: GCP Security Baseline

**CGE-P Certification Lab** | Security Controls Across GCP | NIST 800-53

---

## Overview

Lab 5.4 implements security baseline for GCP - equivalent to Lab 5.2 for AWS. Controls include Cloud Audit Logs, Cloud KMS encryption, IAM RBAC, VPC security, and Binary Authorization.

---

## Controls

| Control | GCP Service | Implementation |
|---------|-------------|-----------------|
| AU-2 | Cloud Audit Logs | API activity logging |
| SC-7 | VPC Service Controls | Network perimeter |
| AC-2 | Cloud IAM | Identity management |
| SC-28 | Cloud KMS | Encryption keys |
| SI-4 | Cloud IDS | Intrusion detection |

---

## Architecture

```
┌──────────────────────────────────────┐
│     GCP Security Baseline            │
├──────────────────────────────────────┤
│ Cloud Audit Logs → Cloud Logging     │
│ Cloud KMS → Encryption               │
│ Cloud IAM → Access control           │
│ VPC Controls → Network security      │
│ Cloud IDS → Threat detection         │
│ Binary Auth → Container security     │
└──────────────────────────────────────┘
```

---

## Key Implementations

### Cloud Audit Logs
```hcl
resource "google_logging_project_sink" "audit_logs" {
  name        = "audit-logs-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.audit_logs.name}"

  filter = <<-EOT
    protoPayload.methodName="storage.buckets.create" OR
    protoPayload.methodName="storage.buckets.delete" OR
    protoPayload.methodName="storage.objects.delete"
  EOT
}
```

### Cloud KMS Encryption
```hcl
resource "google_kms_crypto_key" "default" {
  name            = "gcp-baseline-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "7776000s"  # 90 days
  lifecycle {
    prevent_destroy = true
  }
}
```

### Cloud IAM Least Privilege
```hcl
resource "google_project_iam_member" "minimal_role" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.app.email}"
}
```

---

## Deployment

```bash
cd lab-05-04-gcp-baseline/terraform

export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value project)

terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

---

**Estimated Time:** 40-50 minutes  
**Difficulty:** Advanced  
**GCP Cost:** $1-2/month (Audit Logs, KMS)  

---

*Lab 5.4 created for CGE-P Certification*  
*Date: May 22, 2026*
