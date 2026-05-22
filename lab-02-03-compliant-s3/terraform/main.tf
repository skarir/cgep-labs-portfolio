terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "CGE-P-Lab-2.3"
      ManagedBy   = "Terraform"
      Compliance  = "NIST-800-53"
      Controls    = "SC-28 AU-3 AU-6 CM-6 AC-3"
    }
  }
}

# ============================================================================
# NIST 800-53 Control: SC-28 - Encryption at Rest
# Description: Protect information at rest using cryptographic mechanisms
# Implementation: S3 bucket with AES256 server-side encryption
# ============================================================================
resource "aws_s3_bucket" "compliant_data_bucket" {
  bucket = var.data_bucket_name

  tags = {
    Name                = "Compliant Data Bucket"
    Control             = "SC-28"
    Description         = "Encryption at rest with AES256"
    ComplianceFramework = "NIST-800-53"
    Controls            = "SC-28-1 AU-3-1 AU-6-1 CM-6-1 AC-3-1"
    Evidence            = "S3-Configuration-Compliant"
  }
}

# SC-28(1) - Enable encryption with AWS-managed keys
resource "aws_s3_bucket_server_side_encryption_configuration" "compliant_encryption" {
  bucket = aws_s3_bucket.compliant_data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# ============================================================================
# NIST 800-53 Control: AU-3 & AU-6 - Audit Logging
# Description: Record and review information system activities
# Implementation: Enable access logging to separate logging bucket
# ============================================================================

# Create dedicated logging bucket
resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.logging_bucket_name

  tags = {
    Name        = "Access Logs Bucket"
    Description = "Centralized access logging for audit"
    Control     = "AU-3"
  }
}

# Block public access to logging bucket
resource "aws_s3_bucket_public_access_block" "logging_public_block" {
  bucket = aws_s3_bucket.logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable logging on data bucket
resource "aws_s3_bucket_logging" "compliant_logging" {
  bucket = aws_s3_bucket.compliant_data_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "access-logs/"
}

# ============================================================================
# NIST 800-53 Control: CM-6 - Configuration Management
# Description: Establish and maintain baseline configurations
# Implementation: Enable versioning and block public access
# ============================================================================

# Enable versioning for configuration tracking and audit trail
resource "aws_s3_bucket_versioning" "compliant_versioning" {
  bucket = aws_s3_bucket.compliant_data_bucket.id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled" # Can be enabled with MFA device
  }
}

# ============================================================================
# NIST 800-53 Control: AC-3 - Access Control
# Description: Enforce access restrictions based on the principle of least privilege
# Implementation: Block all public access and implement ACL controls
# ============================================================================

# Block all public access to data bucket
resource "aws_s3_bucket_public_access_block" "compliant_public_block" {
  bucket = aws_s3_bucket.compliant_data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.compliant_data_bucket]
}

# Note: ACL is managed by bucket public access block (most secure default)
# S3 no longer requires explicit ACL configuration with public access blocks enabled

# Bucket policy to enforce SSL/TLS connections (additional AC-3 control)
resource "aws_s3_bucket_policy" "enforce_ssl" {
  bucket = aws_s3_bucket.compliant_data_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceSSLOnly"
        Effect = "Deny"
        Principal = "*"
        Action   = "s3:*"
        Resource = [
          aws_s3_bucket.compliant_data_bucket.arn,
          "${aws_s3_bucket.compliant_data_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.compliant_public_block]
}

# ============================================================================
# Compliance Evidence Tags
# These tags are now included in the main bucket resource above
# ============================================================================
