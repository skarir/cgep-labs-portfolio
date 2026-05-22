#!/bin/bash
# GitHub Push Script for CGE-P Labs Portfolio
# Usage: Follow these commands in order to push your code to GitHub

echo "======================================================================"
echo "CGE-P Labs - GitHub Push Setup"
echo "======================================================================"
echo ""

# STEP 1: Initialize git repository
echo "STEP 1: Initialize Git Repository"
echo "--------------------------------------------------------------------"
echo "cd C:\\Users\\sunil\\cgep-labs-portfolio"
echo "git init"
echo ""

# STEP 2: Configure git (first time only)
echo "STEP 2: Configure Git (First Time Only)"
echo "--------------------------------------------------------------------"
echo "git config --global user.name \"Your Name\""
echo "git config --global user.email \"your.email@example.com\""
echo ""

# STEP 3: Add all files
echo "STEP 3: Add All Files to Git"
echo "--------------------------------------------------------------------"
echo "git add ."
echo "git status"
echo ""

# STEP 4: Create initial commit
echo "STEP 4: Create Initial Commit"
echo "--------------------------------------------------------------------"
echo "git commit -m \"Initial commit: CGE-P Labs - 14 NIST 800-53 controls, 5 labs, 100% compliant\""
echo ""

# STEP 5: Add remote repository
echo "STEP 5: Add Remote Repository"
echo "--------------------------------------------------------------------"
echo "⚠️  REPLACE YOUR_USERNAME WITH YOUR ACTUAL GITHUB USERNAME ⚠️"
echo ""
echo "git remote add origin https://github.com/YOUR_USERNAME/cgep-labs-portfolio.git"
echo ""

# STEP 6: Rename branch to main
echo "STEP 6: Rename Branch to Main"
echo "--------------------------------------------------------------------"
echo "git branch -M main"
echo ""

# STEP 7: Verify remote
echo "STEP 7: Verify Remote Configuration"
echo "--------------------------------------------------------------------"
echo "git remote -v"
echo ""

# STEP 8: Push to GitHub
echo "STEP 8: Push to GitHub"
echo "--------------------------------------------------------------------"
echo "git push -u origin main"
echo ""
echo "⚠️  You'll be prompted for GitHub credentials (use Personal Access Token)"
echo ""

echo "======================================================================"
echo "DONE!"
echo "======================================================================"
echo ""
echo "Your repository should now be visible at:"
echo "https://github.com/YOUR_USERNAME/cgep-labs-portfolio"
echo ""
echo "======================================================================"
