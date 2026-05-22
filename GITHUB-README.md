# CGE-P Labs: Production-Grade Governance, Risk & Compliance Platform

[![NIST 800-53 Compliant](https://img.shields.io/badge/NIST%20800--53-14%2F14%20Controls-brightgreen?style=for-the-badge)](AUDIT-READY-REPORT.md)
[![Compliance Score](https://img.shields.io/badge/Compliance-100%25-brightgreen?style=for-the-badge)](DEPLOYMENT-SUMMARY.md)
[![AWS](https://img.shields.io/badge/AWS-5%20Labs-FF9900?style=for-the-badge&logo=amazon-aws)](DEPLOYMENT-SUMMARY.md)
[![Terraform](https://img.shields.io/badge/Terraform-1.6+-5B4EEF?style=for-the-badge&logo=terraform)](https://www.terraform.io)
[![OSCAL](https://img.shields.io/badge/OSCAL-1.1.0-blue?style=for-the-badge)](lab-06-01-oscal/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

A complete **Infrastructure-as-Code** implementation demonstrating NIST 800-53 compliance with **Evidence-as-Code**, **Policy-as-Code**, and **Compliance-as-Code** automation across AWS.

---

## 🎯 Quick Facts

| Metric | Value |
|--------|-------|
| **NIST 800-53 Controls** | 14/14 ✅ 100% |
| **Labs Deployed** | 5 (2.3, 2.5, 4.3, 4.4, 5.2) |
| **AWS Resources** | 51+ (DynamoDB, S3, Lambda, CloudWatch, etc.) |
| **Compliance Frameworks** | NIST 800-53, SOC 2 Type II, ISO 27001 |
| **Automation** | Daily compliance scoring + real-time monitoring |
| **Evidence Retention** | 7 years (DynamoDB TTL) + 10 years (audit logs) |

---

## 📚 Documentation Hub

### 🚀 Getting Started
- **[README.md](README.md)** - Platform overview and quick start (15 min read)
- **[GITHUB-SETUP-GUIDE.md](GITHUB-SETUP-GUIDE.md)** - How this repository was created

### 🏗️ Architecture & Deployment
- **[DEPLOYMENT-SUMMARY.md](DEPLOYMENT-SUMMARY.md)** - Complete architecture of all 5 labs (45 min read)
  - Lab 2.3: Compliant S3 Buckets
  - Lab 2.5: Evidence Pipeline
  - Lab 5.2: Security Baseline
  - Lab 4.3: GRC Pipeline
  - Lab 4.4: Chain of Custody

### 🔍 Audit & Compliance
- **[AUDIT-READY-REPORT.md](AUDIT-READY-REPORT.md)** - Control assessments, testing procedures, audit schedule (2-3 hr read)
  - 14 control evaluations with verification procedures
  - Testing and audit procedures (14-hour audit timeline)
  - Recommendations and sign-off

### 📋 Package Information
- **[DEPLOYMENT-PACKAGE-MANIFEST.md](DEPLOYMENT-PACKAGE-MANIFEST.md)** - Complete file roadmap and auditor guidance
- **[AUDITOR-SUBMISSION-COVER.md](AUDITOR-SUBMISSION-COVER.md)** - Cover letter for auditors
- **[PACKAGE-COMPLETION-SUMMARY.txt](PACKAGE-COMPLETION-SUMMARY.txt)** - Project completion checklist

### 🔐 OSCAL Documentation (Regulatory Submission)
- **[oscal-system-security-plan.json](lab-06-01-oscal/oscal-system-security-plan.json)** - NIST-compliant SSP (OSCAL 1.1.0)
- **[oscal-component-definitions.json](lab-06-01-oscal/oscal-component-definitions.json)** - Component control mappings

---

## 🏛️ Labs Overview

### Lab 2.3: Compliant S3 Buckets
**Foundation layer with encryption, logging, and access control**
```
Controls: SC-28(1), AU-3(1), CM-6(1), AC-3(1)
Resources: 2 S3 buckets, encryption, versioning, access logs
Status: ✅ Operational
```

### Lab 2.5: Evidence Pipeline
**Automated daily evidence collection with cryptographic integrity**
```
Controls: SC-28(1), SI-10(1)
Resources: DynamoDB, S3, Lambda, EventBridge, KMS
Daily Cycle: 2:30 AM UTC
Flow: Collect → Encrypt → Archive → Verify Hash → Alert
Status: ✅ Operational
```

### Lab 5.2: AWS Security Baseline
**Multi-service security monitoring across AWS**
```
Controls: AU-2(1), SI-4(1), AC-6(1)
Resources: CloudTrail, GuardDuty, IAM, VPC Flow Logs, Config
Monitoring: API logging, threat detection, network monitoring
Status: ✅ Operational
```

### Lab 4.3: GRC Evidence Pipeline
**Continuous compliance monitoring and automated assessment**
```
Controls: CA-7(1)
Resources: DynamoDB, Lambda, EventBridge, SNS, CloudWatch
Daily Workflow: Aggregate evidence → Validate controls → Score compliance → Notify
Assessment: 8 NIST controls evaluated daily
Status: ✅ Operational
```

### Lab 4.4: Chain of Custody
**Evidence integrity and immutable audit trail**
```
Controls: AU-12(1), SI-12(1), CA-9(1)
Resources: DynamoDB (PITR, TTL), CloudWatch (10-year retention), Lambda, EventBridge
Lifecycle: Collection → Verification → Access tracking → Retention → Archival
Status: ✅ Operational
```

---

## 🔐 Security & Compliance Features

### Encryption
- ✅ **At Rest:** S3 AES-256, DynamoDB KMS, Secrets Manager KMS
- ✅ **In Transit:** HTTPS/TLS for all API calls
- ✅ **Key Management:** KMS with automatic rotation

### Access Control
- ✅ **Least Privilege:** Custom IAM policies restricting minimum required actions
- ✅ **Public Access:** S3 buckets completely blocked from public access
- ✅ **Evidence Access:** All access logged with timestamp, user, and reason

### Audit & Monitoring
- ✅ **CloudTrail:** Multi-region API logging with file validation
- ✅ **GuardDuty:** ML-based threat detection
- ✅ **Continuous Monitoring:** Daily compliance assessment + real-time access monitoring
- ✅ **Immutable Audit Trail:** 10-year CloudWatch retention

### Data Protection
- ✅ **7-Year Retention:** DynamoDB TTL with automatic expiration
- ✅ **10-Year Audit Logs:** CloudWatch immutable retention
- ✅ **Hash Verification:** SHA256 for evidence integrity
- ✅ **Point-in-Time Recovery:** DynamoDB PITR capability

---

## 🗂️ Repository Structure

```
cgep-labs-portfolio/
│
├── README.md                              # Main project overview
├── DEPLOYMENT-SUMMARY.md                  # Complete architecture
├── AUDIT-READY-REPORT.md                 # Control assessments
├── DEPLOYMENT-PACKAGE-MANIFEST.md        # File roadmap
├── AUDITOR-SUBMISSION-COVER.md           # Auditor cover letter
├── GITHUB-SETUP-GUIDE.md                 # This repo's setup
├── GITHUB-README.md                      # GitHub-formatted version
│
├── lab-06-01-oscal/                      # OSCAL Audit Documentation
│   ├── README.md
│   ├── oscal-system-security-plan.json   # SSP (NIST-compliant)
│   └── oscal-component-definitions.json  # Control mappings
│
├── lab-04-03-evidence-pipeline/          # GRC Automation
│   ├── README.md
│   ├── terraform/
│   │   ├── main.tf                       # DynamoDB, SNS, Lambda, EventBridge
│   │   └── variables.tf
│   └── lambda/
│       ├── index.py                      # Compliance scoring algorithm
│       └── lambda_grc_aggregator.zip
│
├── lab-04-04-chain-of-custody/           # Evidence Integrity
│   ├── README.md
│   ├── terraform/
│   │   ├── main.tf                       # DynamoDB PITR, CloudWatch, Lambda
│   │   └── variables.tf
│   └── lambda/
│       ├── index.py                      # Chain of custody tracker
│       └── lambda_chain_of_custody.zip
│
├── lab-02-03-s3/                         # Foundation Layer
│   ├── README.md
│   └── terraform/
│       └── main.tf
│
├── lab-02-05-evidence-pipeline/          # Evidence Collection
│   ├── README.md
│   └── terraform/
│
├── lab-05-02-security-baseline/          # Security Monitoring
│   ├── README.md
│   └── terraform/
│
├── .gitignore                             # Excludes sensitive files
└── LICENSE
```

---

## 🚀 Quick Start

### Prerequisites
- AWS Account
- Terraform >= 1.6
- AWS CLI configured

### Deploy All Labs
```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git
cd cgep-labs-portfolio

# Deploy each lab
cd lab-04-03-evidence-pipeline/terraform
terraform init
terraform apply -var aws_region=us-east-1

cd ../../lab-04-04-chain-of-custody/terraform
terraform init
terraform apply -var aws_region=us-east-1

# Verify deployment
aws dynamodb list-tables --query 'TableNames'
aws lambda list-functions --query 'Functions[*].FunctionName'
```

### Verify Compliance
```bash
# Check compliance score
aws dynamodb scan --table-name grc-control-status-lab43-grc

# Review audit trail
aws logs tail /aws/chain-of-custody/evidence-lab44-coc --follow

# View compliance dashboard
# Visit CloudWatch dashboard: cgep-grc-compliance-lab43-grc
```

---

## 📊 NIST 800-53 Control Coverage

All 14 controls implemented and verified:

| Category | Control | Implementation | Status |
|----------|---------|-----------------|--------|
| **SC** | SC-28(1) | S3/DynamoDB encryption | ✅ |
| **AU** | AU-2(1) | CloudTrail logging | ✅ |
| **AU** | AU-3(1) | S3 access logs + metadata | ✅ |
| **AU** | AU-6(1) | CloudWatch analysis | ✅ |
| **AU** | AU-12(1) | Chain of custody logs | ✅ |
| **AC** | AC-3(1) | S3 blocks + IAM policies | ✅ |
| **AC** | AC-6(1) | Least privilege policies | ✅ |
| **CM** | CM-6(1) | Terraform IaC + versioning | ✅ |
| **CA** | CA-7(1) | Daily compliance scoring | ✅ |
| **CA** | CA-9(1) | Event orchestration logs | ✅ |
| **SI** | SI-4(1) | GuardDuty + VPC Flow Logs | ✅ |
| **SI** | SI-10(1) | Hash verification + PITR | ✅ |
| **SI** | SI-12(1) | 7-year TTL retention | ✅ |
| **IA** | IA-2(1) | IAM password policy | ✅ |

**Total: 14/14 Controls = 100% Compliant** ✅

---

## 🎓 For Auditors

### Documentation Review (4 hours)
1. [README.md](README.md) - 10 min overview
2. [DEPLOYMENT-SUMMARY.md](DEPLOYMENT-SUMMARY.md) - 45 min architecture
3. [AUDIT-READY-REPORT.md](AUDIT-READY-REPORT.md) - 2 hrs control details
4. OSCAL documents - 1 hr regulatory format

### Evidence Review (6 hours)
- DynamoDB chain-of-custody table
- CloudWatch 10-year audit logs
- Evidence integrity verification
- Compliance scoring results

### Live Testing (4 hours)
- Evidence collection verification
- Access control testing
- Continuous monitoring validation
- Disaster recovery verification

**Total Audit Time: ~14 hours**

### Audit Access
For live system verification and evidence review, contact: **sunil.karir@gmail.com**

---

## 📈 Compliance Status

| Framework | Status | Details |
|-----------|--------|---------|
| **NIST 800-53** | ✅ Compliant | 14/14 controls implemented |
| **SOC 2 Type II** | ✅ Ready | Evidence integrity, access logging, continuous monitoring |
| **ISO 27001** | ✅ Ready | Information security, asset management, access control |

---

## 🔄 Continuous Operations

### Daily Automated Tasks
- **2:30 AM UTC:** Evidence collection and archival
- **2:30 AM UTC:** Compliance assessment (8 controls evaluated)
- **Real-time:** Evidence access monitoring and logging

### Monitoring & Alerts
- CloudWatch dashboards showing compliance metrics
- SNS notifications on status changes
- Email alerts to: sunil.karir@gmail.com

---

## 🛠️ Technology Stack

| Technology | Purpose | Version |
|-----------|---------|---------|
| **Terraform** | Infrastructure-as-Code | >= 1.6 |
| **AWS** | Cloud Platform | Latest |
| **Python** | Lambda Functions | 3.11 |
| **DynamoDB** | Evidence Storage | (Serverless) |
| **S3** | Archive & Backup | (Regional) |
| **CloudWatch** | Monitoring & Logging | (Global) |
| **EventBridge** | Orchestration | (Regional) |
| **Lambda** | Serverless Computing | (Regional) |
| **KMS** | Encryption Management | (Regional) |
| **CloudTrail** | Audit Logging | (Multi-region) |
| **GuardDuty** | Threat Detection | (Regional) |

---

## 📝 Key Files

### Configuration Files
- `terraform/main.tf` - Infrastructure definitions
- `terraform/variables.tf` - Variable definitions
- `.gitignore` - Sensitive file exclusions

### Lambda Functions
- `lambda/index.py` - Application code
- `lambda/*.zip` - Pre-built packages

### Documentation
- OSCAL SSP - System Security Plan
- OSCAL Components - Control implementations
- Markdown docs - Architecture and procedures

---

## 💡 Use Cases

This platform demonstrates:
- ✅ **Infrastructure-as-Code** - Reproducible deployments
- ✅ **Evidence-as-Code** - Automated evidence collection
- ✅ **Compliance-as-Code** - Daily automated assessment
- ✅ **Policy-as-Code** - IAM enforcement
- ✅ **Audit-Ready** - Complete audit trail
- ✅ **Regulatory Compliance** - NIST, SOC 2, ISO 27001

---

## 🤝 Contributing

This is an audit/demonstration project. For questions or suggestions:

📧 **Email:** sunil.karir@gmail.com  
💬 **GitHub Issues:** Create an issue for questions or feedback

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 🙏 Acknowledgments

This project demonstrates best practices from:
- [NIST SP 800-53 Rev 5](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5)
- [OSCAL (Open Security Controls Assessment Language)](https://pages.nist.gov/OSCAL/)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
- [Terraform Best Practices](https://www.terraform.io/docs/language/values/locals.html)

---

## 🎓 Project Information

- **Author:** Sunil Karir
- **Type:** Production-Grade GRC Platform
- **Framework:** NIST 800-53
- **Cloud:** AWS
- **Status:** ✅ Complete & Operational
- **Created:** 2026-05-22

---

<div align="center">

**⭐ If this project helps you, please consider giving it a star!**

[View Project Documentation](README.md) | [Audit Report](AUDIT-READY-REPORT.md) | [Architecture](DEPLOYMENT-SUMMARY.md)

**Status: ✅ 100% NIST 800-53 Compliant | Audit Ready**

</div>
