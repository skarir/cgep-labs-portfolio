# Lab 6.1: OSCAL - Compliance Documentation

**CGE-P Certification Lab** | OSCAL Framework | Audit-Ready Documentation

---

## Overview

Lab 6.1 uses **OSCAL (Open Security Controls Assessment Language)** to document all 12 labs' compliance in a standardized, machine-readable format suitable for auditors, regulators, and compliance management systems.

---

## OSCAL Documents

### 1. Component Definition (control_implementations.json)

Defines how each infrastructure component implements NIST controls:

```json
{
  "component_definition": {
    "metadata": {
      "title": "CGE-P Labs Compliance Control Implementation",
      "version": "1.0"
    },
    "components": [
      {
        "uuid": "lab-2-3-s3",
        "type": "Software",
        "title": "Lab 2.3: Compliant S3 Bucket",
        "control_implementations": [
          {
            "uuid": "impl-sc28",
            "source": "https://csrc.nist.gov/publications/detail/sp/800-53/rev-5",
            "implemented_requirements": [
              {
                "uuid": "req-sc28-1",
                "control_id": "SC-28(1)",
                "description": "S3 bucket encryption at rest with AES256",
                "statements": [
                  {
                    "statement_id": "sc28-1-statement",
                    "description": "Terraform resource configures encryption"
                  }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}
```

### 2. System Security Plan (ssp.json)

Complete documentation of deployed system:

```json
{
  "system_security_plan": {
    "metadata": {
      "title": "CGE-P Labs System Security Plan",
      "version": "1.0"
    },
    "system_characteristics": {
      "system_name": "CGE-P Multi-Lab Compliance Platform",
      "description": "Integrated infrastructure implementing 50+ NIST 800-53 controls"
    },
    "control_implementation": {
      "description": "Controls implemented across 12 labs",
      "implemented_controls": [
        {
          "control_id": "SC-28(1)",
          "control_statement": "Encrypt information at rest",
          "implementation": "Lab 2.3 S3 bucket, Lab 2.5 DynamoDB, Lab 5.2 KMS keys",
          "status": "Compliant"
        }
      ]
    }
  }
}
```

### 3. Assessment Results (assessment_results.json)

Audit findings and compliance status:

```json
{
  "assessment_results": {
    "metadata": {
      "title": "CGE-P Labs Compliance Assessment",
      "assessment_date": "2026-05-22"
    },
    "results": [
      {
        "control_id": "SC-28(1)",
        "implementation_status": "Compliant",
        "assessment_method": "Technical Assessment",
        "evidence": [
          "Terraform plan shows AES256 encryption enabled",
          "AWS S3 API confirms encryption configured"
        ],
        "findings": []
      }
    ]
  }
}
```

---

## Tools

### OSCAL Validator

Validate your documents:

```bash
oscal-cli validate component cgep-component-definition.json
oscal-cli validate system-security-plan cgep-ssp.json
oscal-cli validate assessment-results cgep-assessment.json
```

### OSCAL Converter

Convert to audit-friendly formats:

```bash
oscal-cli convert cgep-ssp.json --to html > ssp-report.html
oscal-cli convert cgep-assessment.json --to xlsx > assessment-report.xlsx
```

---

## Benefits

✅ **Auditor-Ready:** Standard format understood by all auditors  
✅ **Machine-Readable:** Can be imported into audit management systems  
✅ **Compliant:** Follows NIST standards  
✅ **Provable:** Links infrastructure to controls  
✅ **Traceable:** Complete chain from control to implementation  

---

## Structure

```
lab-06-01-oscal/
├── component-definitions/
│   ├── lab-2-3-s3.json
│   ├── lab-2-5-evidence.json
│   ├── lab-5-2-aws-baseline.json
│   └── lab-5-4-gcp-baseline.json
├── system-security-plans/
│   └── cgep-labs-ssp.json
├── assessment-results/
│   └── cgep-labs-assessment.json
└── README.md
```

---

## Deployment

```bash
cd lab-06-01-oscal

# Validate all documents
oscal-cli validate component component-definitions/*.json
oscal-cli validate system-security-plan system-security-plans/*.json

# Generate audit reports
oscal-cli convert system-security-plans/cgep-labs-ssp.json --to html > ssp-audit-report.html
```

---

## Success Criteria

- [ ] All component definitions validate
- [ ] System security plan complete
- [ ] Assessment results documented
- [ ] HTML audit reports generate
- [ ] All controls mapped to implementations

---

## Interview Talking Points

**"Can you provide audit documentation?"**
> "Yes, immediately. I use OSCAL (Open Security Controls Assessment Language) - a standard format auditors use. The documentation is automatically generated from infrastructure, so it's always current and accurate."

**"How do I import this into our audit system?"**
> "OSCAL is designed for exactly this. Most modern audit management systems support OSCAL import. It's machine-readable, so there's no manual data entry."

---

**Estimated Time:** 20-30 minutes  
**Difficulty:** Beginner (mostly documentation)  
**Cost:** Free (OSCAL is open-source)  

---

*Lab 6.1 created for CGE-P Certification*  
*Date: May 22, 2026*
