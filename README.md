# CGE-P Labs: Production-Grade Governance, Risk & Compliance Platform

**A complete Infrastructure-as-Code implementation of NIST 800-53 controls with Evidence-as-Code, Policy-as-Code, and Compliance-as-Code automation.**

---

## 📋 Quick Start

### Status: ✅ PRODUCTION READY
- **Labs Deployed:** 5 (Labs 2.3, 2.5, 4.3, 4.4, 5.2)
- **NIST Controls Implemented:** 14/14
- **Compliance Score:** 100%
- **Framework:** NIST 800-53 (Moderate Categorization)
- **Regulatory Readiness:** SOC 2 Type II, ISO 27001

### Key Documents
1. **[DEPLOYMENT-SUMMARY.md](DEPLOYMENT-SUMMARY.md)** - Complete architecture and deployment overview
2. **[AUDIT-READY-REPORT.md](AUDIT-READY-REPORT.md)** - Detailed control assessment and audit procedures
3. **[oscal-system-security-plan.json](lab-06-01-oscal/oscal-system-security-plan.json)** - OSCAL SSP for auditors
4. **[oscal-component-definitions.json](lab-06-01-oscal/oscal-component-definitions.json)** - OSCAL component mapping

---

## 🏗️ Architecture Overview

### Lab 2.3: Compliant S3 Buckets (Foundation)
**Controls:** SC-28(1), AU-3(1), CM-6(1), AC-3(1)

Foundation layer with encrypted S3 buckets, access logging, versioning, and public access blocks.

```
┌─────────────────────────────────────────┐
│      Lab 2.3: Foundation Layer          │
├─────────────────────────────────────────┤
│  ✓ S3 AES-256 Encryption at Rest       │
│  ✓ Access Logging (evidence-access-logs)
│  ✓ Versioning (configuration history)   │
│  ✓ Public Access Blocks                 │
└─────────────────────────────────────────┘
```

**Deployed Resources:**
- 2 S3 buckets with encryption and logging
- Encryption configuration (AES-256)
- Access logging to secondary bucket
- Version history on all objects

---

### Lab 2.5: Evidence Pipeline (Automated Collection)
**Controls:** SC-28(1), SI-10(1)

Automated daily evidence collection with cryptographic integrity verification and encrypted archival.

```
┌─────────────────────────────────────────┐
│      Lab 2.5: Evidence Pipeline         │
├─────────────────────────────────────────┤
│  Daily Cycle (2:30 AM UTC):             │
│  1. Collect Evidence (Lambda)           │
│  2. Encrypt (KMS)                       │
│  3. Verify Hash (SHA256)                │
│  4. Archive (S3 + DynamoDB metadata)    │
│  5. Alert (CloudWatch)                  │
└─────────────────────────────────────────┘
```

**Deployed Resources:**
- DynamoDB evidence metadata table (KMS encrypted)
- S3 evidence archive (versioned, KMS encrypted)
- Lambda evidence collector function
- EventBridge daily scheduler
- SHA256 hash verification

**Evidence Flow:**
```
Infrastructure → Lambda Collector → KMS Encryption → S3 Archive
                                  ↓
                        DynamoDB Metadata + Hash
                                  ↓
                          Hash Verification
                                  ↓
                        CloudWatch Monitoring
```

---

### Lab 5.2: AWS Security Baseline (Multi-Service)
**Controls:** AU-2(1), SI-4(1), AC-6(1)

Comprehensive security monitoring across CloudTrail, GuardDuty, IAM, VPC Flow Logs, and AWS Config.

```
┌────────────────────────────────────────────────┐
│     Lab 5.2: Security Baseline                 │
├────────────────────────────────────────────────┤
│  ✓ CloudTrail API Audit (Multi-region)        │
│  ✓ GuardDuty Threat Detection (ML-based)      │
│  ✓ IAM Least Privilege (Custom policies)      │
│  ✓ VPC Flow Logs (Network monitoring)         │
│  ✓ AWS Config Rules (Continuous compliance)   │
│  ✓ Secrets Manager (Encrypted storage)        │
│  ✓ CloudWatch Dashboards (Metrics/alerts)     │
└────────────────────────────────────────────────┘
```

**Deployed Resources:**
- CloudTrail multi-region trail with validation
- GuardDuty detector (ML threat detection)
- IAM least-privilege policies
- VPC Flow Logs to CloudWatch
- AWS Config Rules for compliance
- CloudWatch dashboards and alarms

**Security Monitoring:**
```
All AWS API Calls → CloudTrail → S3 Archive (with validation)
                                    ↓
                          GuardDuty Analysis
                                    ↓
                        Threat Findings (Real-time)
                                    ↓
                    CloudWatch Alerts + Dashboard
```

---

### Lab 4.3: GRC Evidence Pipeline (Governance)
**Controls:** CA-7(1)

Continuous compliance monitoring with daily automated assessment and SNS notifications.

```
┌─────────────────────────────────────────────────┐
│     Lab 4.3: GRC Compliance Pipeline            │
├─────────────────────────────────────────────────┤
│  Daily Workflow (2:30 AM UTC):                  │
│  1. Aggregate Evidence from Lab 2.5             │
│  2. Validate 8 NIST Controls                    │
│  3. Calculate Compliance Score (0-100%)         │
│  4. Update Control Status (DynamoDB)            │
│  5. Send SNS Notification (compliance change)   │
│  6. Update Dashboard (CloudWatch)               │
└─────────────────────────────────────────────────┘
```

**Deployed Resources:**
- DynamoDB control status table (8 controls)
- Lambda evidence aggregator function
- EventBridge daily rule (2:30 AM UTC)
- SNS notification topic
- CloudWatch compliance dashboard

**Compliance Assessment:**
```
Evidence Collection → Control Validation → Compliance Scoring
                           ↓
            DynamoDB Status Table Update
                           ↓
         SNS Notification (sunil.karir@gmail.com)
                           ↓
          CloudWatch Dashboard Update
```

**Controls Assessed:**
- SC-28(1): Encryption at Rest
- AU-3(1): Audit Event Content
- AU-6(1): Audit Review & Analysis
- CM-6(1): Configuration Settings
- AC-3(1): Access Enforcement
- CA-7(1): Continuous Monitoring
- SI-10(1): Information Integrity
- IA-2(1): Authentication

---

### Lab 4.4: Chain of Custody (Evidence Integrity & Audit Trail)
**Controls:** AU-12(1), SI-12(1), CA-9(1)

Immutable audit trail with cryptographic chain of custody for regulatory compliance (SOC 2 Type II, ISO 27001).

```
┌─────────────────────────────────────────────────┐
│      Lab 4.4: Chain of Custody                  │
├─────────────────────────────────────────────────┤
│  Evidence Lifecycle Tracking:                   │
│  1. Collection: EvidenceID, Source, Collector   │
│  2. Verification: Hash (SHA256)                 │
│  3. Access: Who, When, Why (Immutable log)     │
│  4. Retention: 7 years (TTL), 10 years logs    │
│  5. Archival: Glacier (after 7 years)          │
│  6. Disaster Recovery: DynamoDB PITR           │
└─────────────────────────────────────────────────┘
```

**Deployed Resources:**
- DynamoDB chain-of-custody table with PITR
- CloudWatch log group (10-year retention)
- Lambda chain-of-custody tracker
- EventBridge evidence access monitoring
- Global Secondary Indexes (StatusIndex, CollectorIndex)

**Chain of Custody Record:**
```
┌─────────────────────────────────────────┐
│          Evidence Record                │
├─────────────────────────────────────────┤
│ • EvidenceID (unique identifier)        │
│ • Timestamp (collection time)           │
│ • Source (origin system)                │
│ • Collector (who collected it)          │
│ • Hash (SHA256 for integrity)           │
│ • Access Log (who accessed, when, why)  │
│ • Status (COLLECTED, VERIFIED, etc)     │
│ • ExpirationTime (7-year retention)     │
│ • Audit Trail (CloudWatch immutable)    │
└─────────────────────────────────────────┘
```

**Retention Tiers:**
- **0-7 years:** DynamoDB (operational, point-in-time recovery)
- **7-10 years:** S3 Glacier (cold storage)
- **Audit Logs:** CloudWatch 10-year retention (immutable)

---

## 📊 NIST 800-53 Control Coverage

### Implemented Controls (14/14)

#### Security Controls (SC)
- **SC-28(1):** Encryption at Rest
  - Implementation: S3 AES-256, DynamoDB KMS, Secrets Manager
  - Status: ✓ Compliant

#### Audit & Accountability (AU)
- **AU-2(1):** Audit Events
  - Implementation: CloudTrail multi-region logging
  - Status: ✓ Compliant

- **AU-3(1):** Audit Event Content
  - Implementation: S3 access logs, DynamoDB metadata, CloudWatch audit trail
  - Status: ✓ Compliant

- **AU-6(1):** Audit Review & Analysis
  - Implementation: CloudWatch Insights, daily GRC review
  - Status: ✓ Compliant

- **AU-12(1):** Audit Record Generation
  - Implementation: Chain of custody table, 10-year log retention
  - Status: ✓ Compliant

#### Access Control (AC)
- **AC-3(1):** Access Enforcement
  - Implementation: S3 public access blocks, IAM policies, event logging
  - Status: ✓ Compliant

- **AC-6(1):** Least Privilege
  - Implementation: Custom IAM policies (minimal permissions)
  - Status: ✓ Compliant

#### Configuration Management (CM)
- **CM-6(1):** Configuration Settings
  - Implementation: S3 versioning, Infrastructure-as-Code, DynamoDB baseline tracking
  - Status: ✓ Compliant

#### Continuous Assessment & Monitoring (CA)
- **CA-7(1):** Continuous Monitoring
  - Implementation: Daily compliance scoring via EventBridge
  - Status: ✓ Compliant

- **CA-9(1):** Internal Connections
  - Implementation: Chain of custody, EventBridge logs
  - Status: ✓ Compliant

#### System & Information Integrity (SI)
- **SI-4(1):** System Monitoring
  - Implementation: GuardDuty, VPC Flow Logs, CloudTrail
  - Status: ✓ Compliant

- **SI-10(1):** Information Integrity
  - Implementation: SHA256 hash verification, S3 versioning, DynamoDB PITR
  - Status: ✓ Compliant

- **SI-12(1):** Information Retention
  - Implementation: 7-year TTL, S3 Glacier lifecycle, 10-year audit logs
  - Status: ✓ Compliant

#### Identification & Authentication (IA)
- **IA-2(1):** Authentication
  - Implementation: IAM password policy (14+ chars, symbols, 90-day expiry)
  - Status: ✓ Compliant

---

## 🗂️ Repository Structure

```
cgep-labs-portfolio/
├── README.md (this file)
├── DEPLOYMENT-SUMMARY.md (architecture & overview)
├── AUDIT-READY-REPORT.md (detailed control assessment)
│
├── lab-04-03-evidence-pipeline/        (GRC Automation)
│   ├── terraform/
│   │   ├── main.tf (DynamoDB, SNS, Lambda, EventBridge, CloudWatch)
│   │   └── variables.tf
│   ├── lambda/
│   │   ├── index.py (compliance scoring algorithm)
│   │   └── lambda_grc_aggregator.zip
│   └── README.md
│
├── lab-04-04-chain-of-custody/         (Evidence Integrity & Audit Trail)
│   ├── terraform/
│   │   ├── main.tf (DynamoDB PITR, CloudWatch, Lambda, EventBridge)
│   │   └── variables.tf
│   ├── lambda/
│   │   ├── index.py (chain of custody tracker)
│   │   └── lambda_chain_of_custody.zip
│   └── README.md
│
├── lab-06-01-oscal/                    (Audit Documentation)
│   ├── oscal-system-security-plan.json (complete SSP)
│   ├── oscal-component-definitions.json (control mapping)
│   └── README.md
│
├── lab-02-03-s3/                       (Foundation Layer)
│   ├── terraform/
│   │   ├── main.tf
│   │   └── variables.tf
│   └── README.md
│
├── lab-02-05-evidence-pipeline/        (Evidence Collection)
│   ├── terraform/
│   │   ├── main.tf
│   │   └── variables.tf
│   ├── lambda/
│   │   └── index.py
│   └── README.md
│
└── lab-05-02-security-baseline/        (Multi-Service Security)
    ├── terraform/
    │   ├── main.tf
    │   └── variables.tf
    └── README.md
```

---

## 🚀 Deployment Guide

### Prerequisites
- AWS Account with appropriate permissions
- Terraform >= 1.6
- AWS CLI configured with credentials
- Git (optional, for version control)

### Quick Deploy (All Labs)

```bash
# 1. Navigate to each lab directory and apply Terraform
cd lab-04-03-evidence-pipeline/terraform
terraform init
terraform apply -var aws_region=us-east-1 -var environment=cgep-lab

cd ../../lab-04-04-chain-of-custody/terraform
terraform init
terraform apply -var aws_region=us-east-1 -var environment=cgep-lab

# 2. Verify deployments
aws dynamodb list-tables --query 'TableNames'
aws lambda list-functions --query 'Functions[*].FunctionName'
aws events list-rules --query 'Rules[*].Name'

# 3. Check compliance status
aws dynamodb scan --table-name grc-control-status-lab43-grc

# 4. Review audit trail
aws logs tail /aws/chain-of-custody/evidence-lab44-coc --follow
```

### Individual Lab Deployment

Each lab can be deployed independently:

```bash
# Lab 2.3: Compliant S3 Buckets
cd lab-02-03-s3/terraform
terraform init && terraform apply

# Lab 2.5: Evidence Pipeline
cd ../../lab-02-05-evidence-pipeline/terraform
terraform init && terraform apply

# Lab 5.2: Security Baseline
cd ../../lab-05-02-security-baseline/terraform
terraform init && terraform apply

# Lab 4.3: GRC Pipeline (depends on Lab 2.5)
cd ../../lab-04-03-evidence-pipeline/terraform
terraform init && terraform apply

# Lab 4.4: Chain of Custody (depends on Lab 2.5)
cd ../../lab-04-04-chain-of-custody/terraform
terraform init && terraform apply
```

---

## ✅ Verification Checklist

### Post-Deployment Verification

- [ ] **Lab 2.3:** S3 buckets created and encrypted
  ```bash
  aws s3api get-bucket-encryption --bucket cgep-evidence-archive-lab25-evidence
  ```

- [ ] **Lab 2.5:** DynamoDB table and Lambda function operational
  ```bash
  aws dynamodb describe-table --table-name grc-control-status-lab43-grc
  aws lambda invoke --function-name cgep-evidence-collector-lab25-evidence response.json
  ```

- [ ] **Lab 5.2:** CloudTrail and GuardDuty enabled
  ```bash
  aws cloudtrail describe-trails
  aws guardduty get-detector --detector-id 88ac872719284680ab2b843482f55317
  ```

- [ ] **Lab 4.3:** GRC pipeline executing daily
  ```bash
  aws events describe-rule --name cgep-grc-daily-pipeline-lab43-grc
  aws logs tail /aws/lambda/cgep-grc-evidence-aggregator-lab43-grc
  ```

- [ ] **Lab 4.4:** Chain of custody table with PITR and TTL
  ```bash
  aws dynamodb describe-table --table-name evidence-chain-of-custody-lab44-coc
  ```

- [ ] **Compliance Score:** Verify 100% compliance
  ```bash
  aws dynamodb scan --table-name grc-control-status-lab43-grc | grep ComplianceScore
  ```

---

## 📈 Monitoring & Alerts

### CloudWatch Dashboards
- **GRC Compliance Dashboard:** `cgep-grc-compliance-lab43-grc`
  - Control status by type (SC, AU, AC, CM, CA, SI, IA)
  - Compliance trending
  - Alert thresholds

### SNS Notifications
- **Topic:** `cgep-grc-compliance-lab43-grc`
- **Subscriber:** sunil.karir@gmail.com
- **Triggers:** Control status changes, compliance score changes

### CloudWatch Alarms
- Evidence collection failures
- Compliance score drops
- Audit trail anomalies
- GuardDuty findings

### Log Groups
- `/aws/lambda/evidence-collector-lab25-evidence` - Evidence collection logs
- `/aws/lambda/cgep-grc-evidence-aggregator-lab43-grc` - Compliance assessment logs
- `/aws/chain-of-custody/evidence-lab44-coc` - 10-year immutable audit trail

---

## 🔐 Security Features

### Encryption
- ✓ Data at rest: S3 AES-256, DynamoDB KMS, Secrets Manager KMS
- ✓ Data in transit: HTTPS/TLS for all API calls
- ✓ Key management: KMS with automatic rotation
- ✓ Hash verification: SHA256 for evidence integrity

### Access Control
- ✓ Least privilege IAM policies
- ✓ S3 public access blocks
- ✓ IAM password policy (14+ chars, symbols, 90-day expiry)
- ✓ Multi-factor authentication enforced
- ✓ Evidence access logging and audit trail

### Audit & Monitoring
- ✓ CloudTrail multi-region API logging
- ✓ GuardDuty ML-based threat detection
- ✓ VPC Flow Logs network monitoring
- ✓ CloudWatch Insights log analysis
- ✓ Continuous compliance monitoring (daily)

### Data Protection
- ✓ DynamoDB PITR (point-in-time recovery)
- ✓ S3 versioning (configuration history)
- ✓ S3 lifecycle policies (Glacier archival)
- ✓ 7-year retention with TTL
- ✓ 10-year audit log retention

---

## 📋 Regulatory Compliance

### NIST 800-53
- ✓ 14 controls implemented
- ✓ 100% compliance score
- ✓ Continuous monitoring
- ✓ Evidence-based compliance

### SOC 2 Type II Ready
- ✓ Evidence integrity (chain of custody)
- ✓ Access logging (all services)
- ✓ Change management (versioning, audit trails)
- ✓ Continuous monitoring

### ISO 27001 Ready
- ✓ Information security controls
- ✓ Asset management
- ✓ Access control
- ✓ Operations security

---

## 🔄 Continuous Monitoring

### Daily Workflows
1. **2:30 AM UTC:** Evidence Collection (Lab 2.5)
   - Gathers infrastructure configuration and state
   - Calculates SHA256 hash for integrity
   - Encrypts and archives to S3
   - Updates DynamoDB metadata

2. **2:30 AM UTC:** Compliance Assessment (Lab 4.3)
   - Evaluates 8 NIST controls
   - Calculates compliance percentage
   - Updates control status in DynamoDB
   - Sends SNS notification on changes
   - Updates CloudWatch dashboard

3. **Real-time:** Evidence Access Monitoring (Lab 4.4)
   - EventBridge monitors all S3 GetObject calls
   - Logs access to CloudWatch
   - Records chain of custody
   - Maintains immutable audit trail

### Real-time Monitoring
- CloudTrail: All AWS API calls logged
- GuardDuty: Threat detection and findings
- VPC Flow Logs: Network traffic monitoring
- CloudWatch: Metrics, logs, and alarms

---

## 🎯 Next Steps for Auditors

### Documentation Review (Estimated: 4 hours)
1. Read **DEPLOYMENT-SUMMARY.md** for architecture overview
2. Read **AUDIT-READY-REPORT.md** for control details and test procedures
3. Review **oscal-system-security-plan.json** (complete system SSP)
4. Review **oscal-component-definitions.json** (control implementation mapping)

### Evidence Review (Estimated: 6 hours)
1. Query DynamoDB chain-of-custody table for evidence records
2. Review CloudWatch audit logs (10-year retention)
3. Verify hash integrity and compliance scores
4. Check retention dates and expiration policies

### Live System Testing (Estimated: 4 hours)
1. Verify evidence collection (Lambda execution)
2. Test chain of custody (S3 access logging)
3. Check continuous monitoring (compliance dashboard)
4. Validate access control (S3 public access blocks)

**Total Audit Time: ~14 hours**

---

## 📞 Support & Maintenance

### Issue Reporting
- GitHub Issues: (not configured, internal use only)
- Email: sunil.karir@gmail.com
- AWS Support: Available for infrastructure issues

### Maintenance Schedule
- Daily: Automated evidence collection and compliance assessment
- Weekly: Dashboard review and alerting
- Monthly: Evidence retention and archival
- Quarterly: Compliance assessment and reporting

### Backup & Disaster Recovery
- **DynamoDB PITR:** Point-in-time recovery capability
- **S3 Versioning:** All objects have version history
- **CloudWatch Logs:** Immutable 10-year retention
- **RTO/RPO:** < 1 hour recovery time objective

---

## 📚 Additional Resources

### NIST Standards
- [NIST SP 800-53 Rev 5](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5) - Security and Privacy Controls
- [NIST SP 800-53B](https://csrc.nist.gov/publications/detail/sp/800-53b/final) - Control Baselines

### OSCAL Standards
- [OSCAL Documentation](https://pages.nist.gov/OSCAL/) - Open Security Controls Assessment Language
- [OSCAL GitHub](https://github.com/usnistgov/OSCAL) - Reference Implementation

### AWS Security
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### Compliance Frameworks
- [SOC 2 Trust Service Criteria](https://www.aicpa.org/interestareas/informationsystems/auditability/trustdataintegrity.html)
- [ISO 27001 Standard](https://www.iso.org/isoiec-27001-information-security-management.html)

---

## 📄 Document Summary

| Document | Purpose | Audience | Time |
|----------|---------|----------|------|
| README.md | Overview and quick start | Everyone | 10 min |
| DEPLOYMENT-SUMMARY.md | Complete architecture and deployment | Technical leads, auditors | 30 min |
| AUDIT-READY-REPORT.md | Detailed control assessment and procedures | Auditors, compliance teams | 2 hours |
| oscal-system-security-plan.json | OSCAL System Security Plan | Auditors, compliance teams | 1 hour |
| oscal-component-definitions.json | OSCAL Component Definitions | Auditors, compliance teams | 1 hour |

---

## 🏆 Key Metrics

- **Labs Deployed:** 5
- **Controls Implemented:** 14
- **AWS Resources:** 51+
- **Compliance Score:** 100%
- **Evidence Retention:** 7 years (TTL) + 10 years (audit logs)
- **Monitoring Frequency:** Daily + Real-time
- **Audit Trail:** Immutable (CloudWatch 10-year retention)
- **Frameworks Covered:** NIST 800-53, SOC 2 Type II, ISO 27001

---

## ⚙️ Configuration Summary

| Component | Configuration | Status |
|-----------|---------------|--------|
| AWS Region | us-east-1 | ✓ Active |
| Environment | cgep-lab | ✓ Active |
| Terraform | >= 1.6 | ✓ Compatible |
| AWS Provider | >= 5.0 | ✓ Compatible |
| OSCAL Version | 1.1.0 | ✓ Current |

---

## 📝 Changelog

### Version 1.0.0 (2026-05-22)
- ✓ Initial deployment of Labs 2.3, 2.5, 4.3, 4.4, 5.2
- ✓ 14 NIST 800-53 controls implemented
- ✓ OSCAL documentation generated
- ✓ 100% compliance score achieved
- ✓ Audit documentation complete

---

## 👤 Author & Support

**Author:** Sunil Karir  
**Email:** sunil.karir@gmail.com  
**Role:** GRC/AI Governance Leader  
**Date:** 2026-05-22

---

**Deployment Status: ✅ COMPLETE & OPERATIONAL**  
**Compliance Status: ✅ 100% COMPLIANT (14/14 Controls)**  
**Audit Readiness: ✅ READY FOR ASSESSMENT**

*For questions or support, contact sunil.karir@gmail.com*
