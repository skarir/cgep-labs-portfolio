# 🚀 GitHub Setup - START HERE

**Quick Start: 5 minutes to push your code to GitHub**

---

## ⚡ TL;DR (Copy-Paste Commands)

Open PowerShell and run these commands in order:

```powershell
# 1. Navigate to project
cd C:\Users\sunil\cgep-labs-portfolio

# 2. Initialize git
git init

# 3. Configure git (first time only)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 4. Add all files
git add .

# 5. Create commit
git commit -m "Initial commit: CGE-P Labs - 14 NIST 800-53 controls, 5 labs, 100% compliant"

# 6. IMPORTANT: Create GitHub repo at https://github.com/new first!
# Then come back and run:

git remote add origin https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git
git branch -M main
git push -u origin main
```

---

## 📋 Complete Step-by-Step

### Step 0: Create Repository on GitHub (Manual)

1. Go to: https://github.com/new
2. Fill in:
   - **Repository name:** `cgep-labs-portfolio`
   - **Description:** "Production-grade GRC platform with 14 NIST 800-53 controls"
   - **Visibility:** Public (or Private)
   - **DO NOT** add README (we have one)
   - **DO NOT** add .gitignore (we created one)
   - **License:** MIT or Apache 2.0

3. Click **"Create repository"**

4. Copy your URL: `https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git`

---

### Step 1: Open PowerShell

Press `Win + X` and select **Windows PowerShell** (or Terminal)

---

### Step 2: Navigate to Project

```powershell
cd C:\Users\sunil\cgep-labs-portfolio
```

---

### Step 3: Initialize Git

```powershell
git init
```

Expected output:
```
Initialized empty Git repository in C:\Users\sunil\cgep-labs-portfolio\.git/
```

---

### Step 4: Configure Git (First Time Only)

```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Example:
```powershell
git config --global user.name "Sunil Karir"
git config --global user.email "sunil.karir@gmail.com"
```

---

### Step 5: Add Files

```powershell
git add .
```

Verify what will be uploaded:
```powershell
git status
```

You should see all `.md`, `.tf`, `.py`, `.json` files (but NOT `.tfstate` or credentials)

---

### Step 6: Create Commit

```powershell
git commit -m "Initial commit: CGE-P Labs - 14 NIST 800-53 controls, 5 labs, 100% compliant"
```

Expected output:
```
[master (root-commit) abc1234] Initial commit: CGE-P Labs - 14 NIST 800-53 controls...
 XX files changed, XXXXX insertions(+)
```

---

### Step 7: Add Remote

Replace `YOUR_USERNAME` with your actual GitHub username:

```powershell
git remote add origin https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git
```

Example:
```powershell
git remote add origin https://github.com/sunilkarir/cgep-labs-portfolio.git
```

---

### Step 8: Rename Branch

```powershell
git branch -M main
```

---

### Step 9: Push to GitHub

```powershell
git push -u origin main
```

You'll be prompted for credentials:
- **Username:** Your GitHub username
- **Password:** Your Personal Access Token (see below)

---

## 🔑 Getting Your Personal Access Token

GitHub no longer accepts passwords. You need a Personal Access Token:

1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"**
3. Name it: `cgep-labs-push`
4. Select scopes:
   - ✓ `repo` (full control of repositories)
5. Click **"Generate token"**
6. **Copy the token** (you won't see it again!)
7. Use it as your "password" when pushing

---

## ✅ Verify It Worked

Visit: `https://github.com/YOUR_USERNAME/cgep-labs-portfolio`

You should see:
- ✅ All your files uploaded
- ✅ README.md displayed
- ✅ OSCAL JSON files visible
- ✅ Terraform code in folders
- ✅ .gitignore preventing sensitive files

---

## 📁 What Gets Uploaded?

### ✅ WILL BE UPLOADED:
- All `.md` files (documentation)
- All `.tf` files (Terraform code)
- All `.py` files (Python code)
- All `.json` files (OSCAL, config)
- `.zip` files (Lambda packages)
- `.gitignore` (itself)
- Folder structure

### ❌ WILL BE IGNORED (Good Security!):
- `.terraform/` folders
- `*.tfstate` files
- `.env` files
- `*.key` files
- AWS credentials
- `__pycache__/`
- `.vscode/`, `.idea/`
- Any sensitive data

---

## 🆘 Troubleshooting

### "fatal: not a git repository"
```powershell
# Make sure you're in the right directory
cd C:\Users\sunil\cgep-labs-portfolio
git init
```

### "failed to push some refs"
```powershell
# Pull first, then push
git pull origin main
git push origin main
```

### "Permission denied (publickey)"
```powershell
# Use HTTPS instead of SSH
git remote set-url origin https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git
```

### "Support for password authentication was removed"
Use a Personal Access Token instead (see section above)

---

## 🎯 After Push - Customize Your Repository

### Add Description & Tags
1. Go to your repository
2. Click **Settings** (gear icon)
3. Add description and topics:
   - `nist-800-53`
   - `compliance`
   - `grc`
   - `aws`
   - `terraform`
   - `oscal`

### Add Branch Protection (Optional)
1. Go to **Settings** → **Branches**
2. Add protection rule for `main` branch
3. Require pull requests before merge

---

## 📚 Related Documentation

- **[GITHUB-SETUP-GUIDE.md](GITHUB-SETUP-GUIDE.md)** - Detailed guide (5 pages)
- **[GITHUB-README.md](GITHUB-README.md)** - Formatted for GitHub display
- **[GITHUB-PUSH-COMMANDS.sh](GITHUB-PUSH-COMMANDS.sh)** - Shell script version

---

## 🎉 Success Checklist

- [ ] Created GitHub repository
- [ ] Installed Git on your computer
- [ ] Ran `git init` in cgep-labs-portfolio
- [ ] Configured git user name and email
- [ ] Added files with `git add .`
- [ ] Created commit with `git commit -m "..."`
- [ ] Added remote with `git remote add origin ...`
- [ ] Pushed with `git push -u origin main`
- [ ] Verified files appear on GitHub
- [ ] Added description and topics
- [ ] Shared repository URL

---

## 🔗 Your Repository URL

Once you're done, your code will be at:

```
https://github.com/YOUR_USERNAME/cgep-labs-portfolio
```

**Share this with auditors, team members, or for your portfolio!**

---

## 📞 Need Help?

### Git Commands
```powershell
git help                    # Show git help
git status                  # Check what changed
git log --oneline          # View commits
git diff                   # See exact changes
```

### GitHub Desktop (GUI Alternative)
If you prefer a graphical interface:
- Download: https://desktop.github.com
- No command line needed
- Still uses git under the hood

---

## 🎓 Next Steps

### After Your First Push
1. **Share your repo** - Send the GitHub URL to your network
2. **Add to your resume** - Link to your GitHub profile
3. **Enable GitHub Pages** (optional) - Create a project website
4. **Watch for opportunities** - Recruiters can see your work!

### For Future Updates
```powershell
# Make changes to files
# Then:
git add .
git commit -m "Description of changes"
git push
```

---

**That's it! You're ready to go! 🚀**

Questions? Check [GITHUB-SETUP-GUIDE.md](GITHUB-SETUP-GUIDE.md) for more details.
