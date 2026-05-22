# GitHub Setup & Push Guide for CGE-P Labs

**Quick Reference:** Complete setup in 5-10 minutes

---

## ⚡ Quick Start (TL;DR)

```bash
# 1. Initialize git locally
cd C:\Users\sunil\cgep-labs-portfolio
git init
git add .
git commit -m "Initial commit: CGE-P Labs - 14 NIST 800-53 controls, 5 labs, 100% compliant"

# 2. Create repo on GitHub (do this manually on github.com)
# 3. Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git
git branch -M main
git push -u origin main
```

---

## 📋 Step-by-Step Setup Guide

### Step 1: Create GitHub Repository (Manual - on github.com)

1. **Go to GitHub:** https://github.com/new
2. **Fill in repository details:**
   - Repository name: `cgep-labs-portfolio`
   - Description: "Production-grade Governance, Risk & Compliance (GRC) platform demonstrating Infrastructure-as-Code, Evidence-as-Code, Policy-as-Code, and Compliance-as-Code. Implements 14 NIST 800-53 controls across AWS with continuous monitoring and evidence collection."
   - Visibility: **Public** (or Private if preferred)
   - ✅ Check: "Add a README file" - **DO NOT** (we have our own)
   - ✅ Check: "Add .gitignore" - **DO NOT** (we created one)
   - ✅ Check: "Choose a license" - Add MIT or Apache 2.0

3. **Click "Create repository"**

4. **Copy your repository URL** (you'll need it in Step 3)
   - Format: `https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git`

---

### Step 2: Initialize Git Locally

Open PowerShell or Command Prompt and run:

```bash
# Navigate to project directory
cd C:\Users\sunil\cgep-labs-portfolio

# Initialize git
git init

# Configure git (first time only)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify git is initialized
git status
```

**Expected output:**
```
On branch master

No commits yet

nothing to commit
```

---

### Step 3: Add Files and Create Initial Commit

```bash
# Add all files (respects .gitignore)
git add .

# Verify what will be committed
git status

# Create initial commit
git commit -m "Initial commit: CGE-P Labs - 14 NIST 800-53 controls, 5 labs, 100% compliant"
```

**Expected output:**
```
[master (root-commit) abc1234] Initial commit: CGE-P Labs - 14 NIST 800-53 controls...
 XX files changed, XXXXX insertions(+)
```

---

### Step 4: Connect Remote Repository

Replace `YOUR_USERNAME` with your actual GitHub username:

```bash
# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git

# Rename branch to 'main' (GitHub default)
git branch -M main

# Verify remote is set
git remote -v
```

**Expected output:**
```
origin  https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git (fetch)
origin  https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git (push)
```

---

### Step 5: Push to GitHub

```bash
# Push to GitHub (will prompt for credentials)
git push -u origin main
```

**You'll be prompted for GitHub credentials:**
- **Option A:** GitHub Personal Access Token (recommended)
- **Option B:** Username + Password (if not using 2FA)

**For Personal Access Token:**
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token"
3. Select scopes: `repo`, `gist`
4. Copy token and paste when prompted

---

### Step 6: Verify Upload

Visit your repository on GitHub:
```
https://github.com/YOUR_USERNAME/cgep-labs-portfolio
```

You should see all your files! 🎉

---

## 📁 Repository Structure (as it will appear on GitHub)

```
cgep-labs-portfolio/
├── README.md                              ← Main project overview
├── DEPLOYMENT-SUMMARY.md                  ← Complete architecture
├── AUDIT-READY-REPORT.md                 ← Control assessments
├── DEPLOYMENT-PACKAGE-MANIFEST.md        ← File roadmap
├── AUDITOR-SUBMISSION-COVER.md           ← Auditor cover letter
├── PACKAGE-COMPLETION-SUMMARY.txt        ← Completion checklist
├── GITHUB-SETUP-GUIDE.md                 ← This file
│
├── lab-06-01-oscal/
│   ├── README.md
│   ├── oscal-system-security-plan.json
│   └── oscal-component-definitions.json
│
├── lab-04-03-evidence-pipeline/
│   ├── README.md
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── lambda/
│       ├── index.py
│       └── lambda_grc_aggregator.zip
│
├── lab-04-04-chain-of-custody/
│   ├── README.md
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── lambda/
│       ├── index.py
│       └── lambda_chain_of_custody.zip
│
├── lab-02-03-s3/
│   ├── README.md
│   └── terraform/
│       ├── main.tf
│       └── variables.tf
│
├── lab-02-05-evidence-pipeline/
│   ├── README.md
│   ├── terraform/
│   └── lambda/
│
├── lab-05-02-security-baseline/
│   ├── README.md
│   └── terraform/
│
├── .gitignore                             ← Prevents sensitive files upload
└── .git/                                  ← Git metadata (hidden)
```

---

## 🔐 Security: What Gets Ignored

The `.gitignore` file prevents these from being uploaded:

✅ **Automatically Excluded:**
- `.terraform/` - Terraform cache
- `*.tfstate` - Terraform state files
- `.env` files - Environment variables
- `*.key`, `*.pem` - SSH/SSL keys
- AWS credentials
- `__pycache__/` - Python cache
- `.vscode/`, `.idea/` - IDE config
- Node modules, Python venv, etc.

✅ **What Gets Uploaded:**
- `.tf` files - Terraform code ✓
- `.py` files - Python code ✓
- `.json` files - Config and OSCAL docs ✓
- `.md` files - Documentation ✓
- `.zip` files - Pre-built Lambda packages ✓

---

## 📝 Creating Repository Description

On GitHub, edit your repo settings to add:

**Description:**
```
Production-grade Governance, Risk & Compliance (GRC) platform implementing 
14 NIST 800-53 controls across AWS. Features Infrastructure-as-Code, 
Evidence-as-Code, Policy-as-Code, and Compliance-as-Code automation.
```

**Topics (tags):**
- `nist-800-53`
- `compliance`
- `grc`
- `aws`
- `terraform`
- `infrastructure-as-code`
- `oscal`

---

## 🔄 Future Commits (After Initial Push)

Once you've pushed the initial code, making updates is simple:

```bash
# Make changes to files

# Stage changes
git add .

# Create commit
git commit -m "Description of changes"

# Push to GitHub
git push
```

---

## 🚨 Troubleshooting

### Error: "failed to push some refs to origin"

**Solution:** Pull first, then push
```bash
git pull origin main
git push origin main
```

### Error: "Permission denied (publickey)"

**Solution:** Use HTTPS instead of SSH
```bash
git remote set-url origin https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git
git push -u origin main
```

### Error: "Support for password authentication was removed"

**Solution:** Use Personal Access Token instead (see Step 5)

### Accidentally added sensitive files?

**Solution:** Remove from git history
```bash
# Remove from tracking (but keep local copy)
git rm --cached sensitive-file.txt

# Add to .gitignore
echo "sensitive-file.txt" >> .gitignore

# Commit the change
git add .gitignore
git commit -m "Remove sensitive file from tracking"
git push
```

---

## 📊 Repository Badges (Optional)

Add to your README.md for visual appeal:

```markdown
# CGE-P Labs Compliance Platform

[![NIST 800-53 Compliant](https://img.shields.io/badge/NIST%20800--53-14%2F14%20Controls-brightgreen)](AUDIT-READY-REPORT.md)
[![Compliance Score](https://img.shields.io/badge/Compliance%20Score-100%25-brightgreen)](AUDIT-READY-REPORT.md)
[![AWS](https://img.shields.io/badge/AWS-5%20Labs-FF9900)](DEPLOYMENT-SUMMARY.md)
[![Terraform](https://img.shields.io/badge/Terraform-1.6+-5B4EEF)](https://www.terraform.io)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

Production-grade GRC platform with Infrastructure-as-Code, Evidence-as-Code, 
and Compliance-as-Code automation.
```

---

## 📚 GitHub Repository Best Practices

### Good README Structure (Already Done ✓)
- ✓ Project title and description
- ✓ Quick start guide
- ✓ Architecture overview
- ✓ Installation instructions
- ✓ Deployment guide
- ✓ Documentation links
- ✓ Contact information

### Good Repository Structure (Ready to Upload ✓)
- ✓ Organized by lab/function
- ✓ Terraform code separated from Lambda
- ✓ Documentation at root level
- ✓ OSCAL artifacts in dedicated folder
- ✓ .gitignore to exclude sensitive files

### Good Commit Messages (Use These ✓)
```
"Initial commit: CGE-P Labs - 14 NIST 800-53 controls, 5 labs, 100% compliant"

"Add Lab 4.3: GRC Evidence Pipeline - continuous monitoring and compliance scoring"

"Add Lab 4.4: Chain of Custody - evidence integrity and 10-year audit trail"

"Update OSCAL documentation - System Security Plan and Component Definitions"

"Fix: DynamoDB stream configuration for change tracking"
```

---

## 🎯 After Your First Push

### Make Your Repository Discoverable

1. **Add GitHub Topics:**
   - compliance, nist, aws, terraform, grc, oscal

2. **Enable GitHub Features:**
   - ✓ Issues (for tracking improvements)
   - ✓ Discussions (for questions)
   - ✓ Wiki (for documentation)

3. **Create GitHub Pages (Optional):**
   - Deploy README as website
   - Link to documentation

4. **Add Branch Protection:**
   - Require pull requests for main branch
   - Require code review before merge

---

## 📞 Support

### Git Help Commands
```bash
git help <command>              # Show help for a command
git status                      # Show current status
git log --oneline              # Show commit history
git diff                        # Show changes
git branch -v                   # Show branches
```

### GitHub Desktop (GUI Alternative)
If you prefer a graphical interface:
- Download: https://desktop.github.com
- Easier than command line for beginners
- Still uses git under the hood

---

## ✅ Verification Checklist

- [ ] Created GitHub account (if not already done)
- [ ] Created repository on github.com
- [ ] Ran `git init` locally
- [ ] Added files with `git add .`
- [ ] Created initial commit
- [ ] Added remote origin
- [ ] Pushed to GitHub with `git push -u origin main`
- [ ] Verified files appear on GitHub
- [ ] Added repository description and topics
- [ ] Shared repository URL with team/auditors

---

## 🎉 Success!

Once you see your files on GitHub, you're done! 

Your repository is now:
- ✅ Publicly accessible
- ✅ Version controlled
- ✅ Backed up in the cloud
- ✅ Ready for collaboration
- ✅ Audit-ready for submission

**Share your repository URL:**
```
https://github.com/YOUR_USERNAME/cgep-labs-portfolio
```

---

*This guide was created to help you quickly set up GitHub for the CGE-P Labs project.*
*For questions, contact: sunil.karir@gmail.com*
