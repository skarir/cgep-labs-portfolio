# GCP Setup for CGE-P Labs

**Time Required:** 10-15 minutes  
**Cost:** Free tier with $300 credit (first 3 months)  
**Required for:** Labs 2.4, 3.3, 5.4

---

## Quick Start (5 minutes)

### Step 1: Create Google Cloud Account
1. Visit: https://cloud.google.com/free
2. Click "Get started for free"
3. Sign in with your Google account (or create one)
4. Fill in billing information
5. Accept terms and create project

### Step 2: Create Project
1. Go to: https://console.cloud.google.com/projectcreate
2. Enter project name: `cgep-labs`
3. Select organization: (leave as is for personal account)
4. Click "Create"

### Step 3: Install Google Cloud SDK
```bash
# Windows (using winget)
winget install Google.CloudSDK

# Then initialize
gcloud init
```

### Step 4: Authenticate
```bash
gcloud auth login
gcloud config set project cgep-labs
```

### Step 5: Verify Setup
```bash
gcloud auth list
gcloud config list
gcloud compute projects list
```

---

## Detailed Setup Steps

### Enable Required APIs

For the labs to work, enable these APIs in Cloud Console:

1. **Go to APIs & Services Dashboard:**
   https://console.cloud.google.com/apis/dashboard

2. **Enable these APIs:**
   - Compute Engine API
   - Cloud Storage API
   - Cloud Logging API
   - Cloud Monitoring API
   - IAM API

3. **Or use CLI:**
```bash
gcloud services enable compute.googleapis.com
gcloud services enable storage-component.googleapis.com
gcloud services enable logging.googleapis.com
gcloud services enable monitoring.googleapis.com
gcloud services enable iam.googleapis.com
```

### Create Service Account

Required for Terraform to deploy resources:

```bash
# Create service account
gcloud iam service-accounts create cgep-terraform \
  --display-name="CGEP Terraform Service Account"

# Grant necessary roles
gcloud projects add-iam-policy-binding cgep-labs \
  --member=serviceAccount:cgep-terraform@cgep-labs.iam.gserviceaccount.com \
  --role=roles/editor

# Create and download key
gcloud iam service-accounts keys create \
  ~/cgep-terraform-key.json \
  --iam-account=cgep-terraform@cgep-labs.iam.gserviceaccount.com

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS=~/cgep-terraform-key.json
```

### Verify GCP Setup

```bash
# List projects
gcloud projects list

# List service accounts
gcloud iam service-accounts list

# Test access
gsutil ls  # Should list your GCS buckets (empty initially)
```

---

## For Each Lab

### Lab 2.4: Terraform Modules (GCP)
```bash
cd lab-02-04-terraform-modules/gcp
terraform init
terraform plan
terraform apply
```

### Lab 3.3: Rego Policies (GCP)
```bash
cd lab-03-03-rego-policies
# Uses existing infrastructure or new GCP resources
```

### Lab 5.4: GCP Security Baseline
```bash
cd lab-05-04-gcp-baseline
terraform init
terraform plan
terraform apply
```

---

## Troubleshooting

### "gcloud command not found"
**Solution:** Add gcloud to PATH or restart terminal after installation

### "Permission denied" when applying Terraform
**Solution:** Ensure service account has correct roles:
```bash
gcloud projects add-iam-policy-binding cgep-labs \
  --member=serviceAccount:cgep-terraform@cgep-labs.iam.gserviceaccount.com \
  --role=roles/editor
```

### "Project not found"
**Solution:** Verify project exists:
```bash
gcloud projects list
gcloud config set project cgep-labs  # Set active project
```

### Billing alerts
**Solution:** Set budget alerts:
1. Go to Billing → Budgets & alerts
2. Create alert for $50 (half of free tier)
3. Never worry about surprise charges

---

## Estimated Costs (Labs only)

| Resource | Estimated Cost |
|----------|---|
| **Compute (if used)** | Free tier (750 hrs/month) |
| **Storage (if used)** | ~$0.02 per lab |
| **Data transfer** | Free tier (1GB/month) |
| **Total estimated** | < $0.10 |

**With free tier credit:** $0 out of pocket

---

## Keep Your API Key Safe

**IMPORTANT:** Never commit `cgep-terraform-key.json` to Git!

Add to `.gitignore`:
```
cgep-terraform-key.json
*.key.json
terraform.tfvars
.env
```

---

## When You're Done

Destroy GCP resources to avoid any charges:

```bash
cd lab-05-04-gcp-baseline
terraform destroy

# Or manual cleanup via Console
```

---

**Ready?** Run the commands above and let me know when GCP is set up!
