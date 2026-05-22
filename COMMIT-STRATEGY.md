# CGE-P Labs - Commit Strategy & Examples

This guide shows good commit practices for your project and provides examples of commits you should make.

---

## 📋 Commit Message Format

### Good Commit Message
```
Type: Brief description (50 chars or less)

Optional detailed explanation (if needed)
```

### Types
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation update
- `refactor:` - Code reorganization
- `test:` - Test additions
- `chore:` - Maintenance, dependencies

---

## 🚀 Initial & Foundation Commits

### Commit 1: Initial Setup (ALREADY DONE)
```
git commit -m "Initial commit: CGE-P Labs - 14 NIST 800-53 controls, 5 labs, 100% compliant"
```
✅ Already completed

---

## 📚 Documentation Commits

### Commit 2: Add Comprehensive Documentation
```
git commit -m "docs: Add deployment summary and audit-ready documentation"
```
**Changes:**
- DEPLOYMENT-SUMMARY.md
- AUDIT-READY-REPORT.md
- DEPLOYMENT-PACKAGE-MANIFEST.md

**Run this:**
```powershell
git add DEPLOYMENT-SUMMARY.md AUDIT-READY-REPORT.md DEPLOYMENT-PACKAGE-MANIFEST.md
git commit -m "docs: Add deployment summary and audit-ready documentation"
git push
```

---

### Commit 3: Add OSCAL Audit Documents
```
git commit -m "docs: Add OSCAL SSP and component definitions for regulatory compliance"
```
**Changes:**
- lab-06-01-oscal/oscal-system-security-plan.json
- lab-06-01-oscal/oscal-component-definitions.json

**Run this:**
```powershell
git add lab-06-01-oscal/
git commit -m "docs: Add OSCAL SSP and component definitions for regulatory compliance"
git push
```

---

### Commit 4: Add GitHub Setup Guides
```
git commit -m "docs: Add GitHub setup and deployment guides"
```
**Changes:**
- GITHUB-SETUP-GUIDE.md
- GITHUB-README.md
- START-HERE-GITHUB.md
- .gitignore

**Run this:**
```powershell
git add GITHUB-SETUP-GUIDE.md GITHUB-README.md START-HERE-GITHUB.md .gitignore
git commit -m "docs: Add GitHub setup and deployment guides"
git push
```

---

## 🏗️ Lab-Specific Commits

### Commit 5: Lab 2.3 - Compliant S3 Buckets
```
git commit -m "feat: Lab 2.3 - Compliant S3 buckets with encryption and logging"
```
**Changes:**
- lab-02-03-s3/terraform/main.tf
- lab-02-03-s3/terraform/variables.tf
- lab-02-03-s3/README.md

**Controls:**
- SC-28(1): Encryption at Rest
- AU-3(1): Audit Event Content
- CM-6(1): Configuration Settings
- AC-3(1): Access Enforcement

**Run this:**
```powershell
git add lab-02-03-s3/
git commit -m "feat: Lab 2.3 - Compliant S3 buckets with encryption and logging`n`nImplements 4 NIST 800-53 controls:`n- SC-28(1): S3 AES-256 encryption`n- AU-3(1): S3 access logging`n- CM-6(1): S3 versioning`n- AC-3(1): Public access blocks"
git push
```

---

### Commit 6: Lab 2.5 - Evidence Pipeline
```
git commit -m "feat: Lab 2.5 - Automated evidence collection pipeline with KMS encryption"
```
**Changes:**
- lab-02-05-evidence-pipeline/terraform/main.tf
- lab-02-05-evidence-pipeline/terraform/variables.tf
- lab-02-05-evidence-pipeline/lambda/index.py
- lab-02-05-evidence-pipeline/README.md

**Controls:**
- SC-28(1): Encryption at Rest (DynamoDB + S3 KMS)
- SI-10(1): Information Integrity (Hash verification)

**Run this:**
```powershell
git add lab-02-05-evidence-pipeline/
git commit -m "feat: Lab 2.5 - Automated evidence collection pipeline with KMS encryption`n`nDaily evidence collection with:`n- DynamoDB encrypted metadata table`n- S3 encrypted archive`n- SHA256 hash verification`n- Lambda processor`n- EventBridge scheduler"
git push
```

---

### Commit 7: Lab 5.2 - Security Baseline
```
git commit -m "feat: Lab 5.2 - AWS security baseline with CloudTrail, GuardDuty, IAM"
```
**Changes:**
- lab-05-02-security-baseline/terraform/main.tf
- lab-05-02-security-baseline/terraform/variables.tf
- lab-05-02-security-baseline/README.md

**Controls:**
- AU-2(1): Audit Events (CloudTrail)
- SI-4(1): System Monitoring (GuardDuty + VPC Flow Logs)
- AC-6(1): Least Privilege (IAM policies)

**Run this:**
```powershell
git add lab-05-02-security-baseline/
git commit -m "feat: Lab 5.2 - AWS security baseline with CloudTrail, GuardDuty, IAM`n`nImplements 3 NIST 800-53 controls:`n- AU-2(1): Multi-region CloudTrail logging`n- SI-4(1): GuardDuty threat detection + VPC Flow Logs`n- AC-6(1): IAM least privilege policies"
git push
```

---

### Commit 8: Lab 4.3 - GRC Pipeline
```
git commit -m "feat: Lab 4.3 - GRC evidence pipeline with continuous compliance scoring"
```
**Changes:**
- lab-04-03-evidence-pipeline/terraform/main.tf
- lab-04-03-evidence-pipeline/terraform/variables.tf
- lab-04-03-evidence-pipeline/lambda/index.py
- lab-04-03-evidence-pipeline/README.md

**Controls:**
- CA-7(1): Continuous Monitoring

**Run this:**
```powershell
git add lab-04-03-evidence-pipeline/
git commit -m "feat: Lab 4.3 - GRC evidence pipeline with continuous compliance scoring`n`nDaily compliance assessment:`n- Evaluates 8 NIST controls`n- Calculates compliance percentage`n- Updates DynamoDB status table`n- Sends SNS notifications`n- Updates CloudWatch dashboard"
git push
```

---

### Commit 9: Lab 4.4 - Chain of Custody
```
git commit -m "feat: Lab 4.4 - Chain of custody with evidence integrity and 10-year audit trail"
```
**Changes:**
- lab-04-04-chain-of-custody/terraform/main.tf
- lab-04-04-chain-of-custody/terraform/variables.tf
- lab-04-04-chain-of-custody/lambda/index.py
- lab-04-04-chain-of-custody/README.md

**Controls:**
- AU-12(1): Audit Record Generation
- SI-12(1): Information Retention
- CA-9(1): Internal Connections

**Run this:**
```powershell
git add lab-04-04-chain-of-custody/
git commit -m "feat: Lab 4.4 - Chain of custody with evidence integrity and 10-year audit trail`n`nImplements 3 NIST 800-53 controls:`n- AU-12(1): DynamoDB chain of custody table`n- SI-12(1): 7-year TTL + 10-year CloudWatch retention`n- CA-9(1): EventBridge evidence tracking logs`n`nFeatures:`n- DynamoDB PITR for recovery`n- SHA256 hash verification`n- Immutable CloudWatch audit trail"
git push
```

---

## 🔧 Maintenance & Fixes

### Commit 10: Fix DynamoDB Stream Configuration
```
git commit -m "fix: Correct DynamoDB stream configuration for Lab 4.4"
```
**Changes:**
- lab-04-04-chain-of-custody/terraform/main.tf

**Details:**
Changed from invalid `stream_specification` block to direct `stream_view_type` attribute.

**Run this:**
```powershell
git add lab-04-04-chain-of-custody/terraform/main.tf
git commit -m "fix: Correct DynamoDB stream configuration for Lab 4.4`n`nChanged from stream_specification block to stream_view_type attribute`nfor proper NEW_AND_OLD_IMAGES tracking"
git push
```

---

### Commit 11: Fix CloudWatch Log Retention
```
git commit -m "fix: Correct CloudWatch log retention to maximum allowed value"
```
**Changes:**
- lab-04-04-chain-of-custody/terraform/main.tf

**Details:**
AWS only allows specific retention values. Changed from calculated 2555 days to maximum allowed 3653 days.

**Run this:**
```powershell
git add lab-04-04-chain-of-custody/terraform/main.tf
git commit -m "fix: Correct CloudWatch log retention to maximum allowed value`n`nAWS only allows specific retention_in_days values`nChanged to 3653 (max allowed, approximately 10 years)"
git push
```

---

## 📖 Future Commits (When You Make Changes)

### When Adding a New Feature
```powershell
git add path/to/changed/files
git commit -m "feat: Description of new feature`n`nDetailed explanation of what was added`nand why"
git push
```

### When Fixing a Bug
```powershell
git add path/to/changed/files
git commit -m "fix: Description of bug fix`n`nExplain the bug and how it was fixed"
git push
```

### When Updating Documentation
```powershell
git add path/to/changed/docs
git commit -m "docs: Update documentation with new details"
git push
```

---

## 📊 Complete Commit History (Timeline)

```
Commit 1 (May 22, 10:00 AM)
├─ Initial commit: All files uploaded
│
Commit 2 (May 22, 11:00 AM)
├─ docs: Add deployment summary and audit documentation
│
Commit 3 (May 22, 12:00 PM)
├─ docs: Add OSCAL SSP and component definitions
│
Commit 4 (May 22, 1:00 PM)
├─ docs: Add GitHub setup and deployment guides
│
Commit 5 (May 22, 2:00 PM)
├─ feat: Lab 2.3 - Compliant S3 buckets
│
Commit 6 (May 22, 3:00 PM)
├─ feat: Lab 2.5 - Evidence collection pipeline
│
Commit 7 (May 22, 4:00 PM)
├─ feat: Lab 5.2 - Security baseline
│
Commit 8 (May 22, 5:00 PM)
├─ feat: Lab 4.3 - GRC pipeline
│
Commit 9 (May 22, 6:00 PM)
├─ feat: Lab 4.4 - Chain of custody
│
Commit 10 (May 22, 7:00 PM)
├─ fix: DynamoDB stream configuration
│
Commit 11 (May 22, 8:00 PM)
├─ fix: CloudWatch log retention
```

---

## 🎯 How to Make a Commit

### 1. Make Changes to Files
Edit any file(s) in your project

### 2. Stage Changes
```powershell
# Stage specific file
git add path/to/file.txt

# Stage all changes
git add .

# Stage specific folder
git add folder/
```

### 3. Check What's Staged
```powershell
git status
```

### 4. Create Commit
```powershell
git commit -m "Your commit message here"
```

### 5. Push to GitHub
```powershell
git push
```

---

## 💡 Good Commit Practices

### ✅ DO:
- Write clear, descriptive messages
- Commit related changes together
- Commit frequently (don't wait)
- Reference NIST controls in commit messages
- Explain WHY, not just WHAT

### ❌ DON'T:
- Commit huge changes in one commit
- Write vague messages like "update"
- Commit credentials or secrets
- Commit before testing
- Leave commits for later (do them immediately)

---

## 📚 Commit Message Examples

### Good Examples ✅
```
feat: Lab 2.3 - Add S3 encryption and logging

docs: Update README with deployment instructions

fix: Correct DynamoDB TTL configuration

refactor: Simplify Lambda function code

test: Add unit tests for compliance scoring
```

### Bad Examples ❌
```
update files

fixed stuff

changes

asdf

wtf
```

---

## 🔍 View Your Commits

### See all commits
```powershell
git log
```

### See commits in one-line format
```powershell
git log --oneline
```

### See commits with file changes
```powershell
git log --stat
```

### See specific file history
```powershell
git log -- filename.txt
```

---

## 🌳 See Your Commit Tree on GitHub

Once you push commits, visit:
```
https://github.com/skarir/cgep-labs-portfolio
```

Click on the **commit count** (e.g., "15 commits") to see your full history with all messages!

---

## 📞 Need Help?

If you make a mistake:
```powershell
# Undo last commit (keeps changes)
git reset --soft HEAD~1

# See what changed in last commit
git show HEAD

# Compare commits
git diff COMMIT1 COMMIT2
```

---

**That's it! Now you know how to make commits. Start with the example commits above!** 🚀
