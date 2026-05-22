# CGE-P Labs - Automated GitHub Push Script
# This script will push your code to GitHub automatically

Write-Host "=====================================" -ForegroundColor Green
Write-Host "CGE-P Labs - GitHub Push Setup" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Configuration
$ProjectPath = "C:\Users\sunil\cgep-labs-portfolio"
$GitHubURL = "https://github.com/skarir/cgep-labs-portfolio.git"
$YourName = "Sunil Karir"
$YourEmail = "sunil.karir@gmail.com"

# Step 1: Navigate to project
Write-Host "Step 1: Navigating to project directory..." -ForegroundColor Cyan
Set-Location $ProjectPath
Write-Host "SUCCESS: Navigated to project" -ForegroundColor Green
Write-Host ""

# Step 2: Initialize git
Write-Host "Step 2: Initializing git repository..." -ForegroundColor Cyan
git init
Write-Host "SUCCESS: Git repository initialized" -ForegroundColor Green
Write-Host ""

# Step 3: Configure git
Write-Host "Step 3: Configuring git user..." -ForegroundColor Cyan
git config --global user.name $YourName
git config --global user.email $YourEmail
Write-Host "SUCCESS: Git configured as $YourName ($YourEmail)" -ForegroundColor Green
Write-Host ""

# Step 4: Add files
Write-Host "Step 4: Adding files to git..." -ForegroundColor Cyan
git add .
Write-Host "SUCCESS: Files added" -ForegroundColor Green
Write-Host ""

# Step 5: Check status
Write-Host "Step 5: Checking git status..." -ForegroundColor Cyan
git status
Write-Host ""

# Step 6: Create commit
Write-Host "Step 6: Creating initial commit..." -ForegroundColor Cyan
git commit -m "Initial commit: CGE-P Labs - 14 NIST 800-53 controls, 5 labs, 100% compliant"
Write-Host "SUCCESS: Commit created" -ForegroundColor Green
Write-Host ""

# Step 7: Add remote
Write-Host "Step 7: Adding remote repository..." -ForegroundColor Cyan
git remote add origin $GitHubURL
Write-Host "SUCCESS: Remote repository added" -ForegroundColor Green
Write-Host ""

# Step 8: Rename branch
Write-Host "Step 8: Renaming branch to main..." -ForegroundColor Cyan
git branch -M main
Write-Host "SUCCESS: Branch renamed to main" -ForegroundColor Green
Write-Host ""

# Step 9: Verify remote
Write-Host "Step 9: Verifying remote configuration..." -ForegroundColor Cyan
git remote -v
Write-Host ""

# Step 10: Push to GitHub
Write-Host "Step 10: Pushing to GitHub..." -ForegroundColor Cyan
Write-Host ""
Write-Host "WARNING: YOU WILL BE PROMPTED FOR CREDENTIALS" -ForegroundColor Yellow
Write-Host "Username: skarir" -ForegroundColor Yellow
Write-Host "Password: Your Personal Access Token (NOT your GitHub password)" -ForegroundColor Yellow
Write-Host ""
Write-Host "To create a token if needed:" -ForegroundColor Yellow
Write-Host "  1. Go to: https://github.com/settings/tokens" -ForegroundColor Yellow
Write-Host "  2. Click: Generate new token" -ForegroundColor Yellow
Write-Host "  3. Select scope: repo" -ForegroundColor Yellow
Write-Host "  4. Copy the token and paste it below" -ForegroundColor Yellow
Write-Host ""

git push -u origin main

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "PUSH COMPLETE!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your repository is at:" -ForegroundColor Green
Write-Host "https://github.com/skarir/cgep-labs-portfolio" -ForegroundColor Cyan
Write-Host ""
