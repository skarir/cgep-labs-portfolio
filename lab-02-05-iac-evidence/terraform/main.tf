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
      Project     = "CGE-P-Lab-2.5"
      ManagedBy   = "Terraform"
      Compliance  = "NIST-800-53"
      Controls    = "SC-28 AU-3 AU-6 SI-10"
    }
  }
}

# ============================================================================
# Lab 2.5: IaC as Compliance Evidence
# Description: Automated evidence collection and storage pipeline
# Controls: SC-28 (encryption), AU-3/AU-6 (logging/audit), SI-10 (evidence integrity)
# ============================================================================

# Reference the S3 bucket from Lab 2.3
data "aws_s3_bucket" "lab23_data_bucket" {
  bucket = var.lab23_data_bucket_name
}

# ============================================================================
# Evidence Storage: DynamoDB Table for Evidence Metadata
# Control: SI-10 - Evidence integrity and completeness
# ============================================================================

resource "aws_dynamodb_table" "evidence_metadata" {
  name           = "cgep-lab-evidence-metadata-${var.lab_identifier}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "EvidenceID"
  range_key      = "Timestamp"

  attribute {
    name = "EvidenceID"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "S"
  }

  attribute {
    name = "ControlID"
    type = "S"
  }

  # Global Secondary Index for querying by control
  global_secondary_index {
    name            = "ControlIDIndex"
    hash_key        = "ControlID"
    range_key       = "Timestamp"
    projection_type = "ALL"
  }

  # Enable encryption at rest
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.evidence_key.arn
  }

  # Enable point-in-time recovery for evidence protection
  point_in_time_recovery {
    enabled = true
  }

  # Enable TTL for evidence retention policy
  ttl {
    attribute_name = "ExpirationTime"
    enabled        = true
  }

  tags = {
    Name        = "Evidence Metadata Store"
    Control     = "SI-10"
    Description = "DynamoDB table for evidence metadata tracking"
    Purpose     = "Compliance evidence collection and audit trail"
  }
}

# ============================================================================
# Encryption Key for DynamoDB Evidence Storage
# Control: SC-28 - Encryption at rest for evidence integrity
# ============================================================================

resource "aws_kms_key" "evidence_key" {
  description             = "KMS key for encrypting evidence data at rest"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name    = "Evidence Encryption Key"
    Control = "SC-28-1"
  }
}

resource "aws_kms_alias" "evidence_key_alias" {
  name          = "alias/cgep-lab-evidence-${var.lab_identifier}"
  target_key_id = aws_kms_key.evidence_key.key_id
}

# ============================================================================
# Evidence Collection S3 Bucket
# Control: SC-28 - Encryption at rest
# Control: AU-3/AU-6 - Access logging and audit trail
# ============================================================================

resource "aws_s3_bucket" "evidence_archive" {
  bucket = "cgep-evidence-archive-${var.lab_identifier}"

  tags = {
    Name        = "Evidence Archive"
    Control     = "SC-28 AU-3 AU-6"
    Description = "Encrypted evidence repository with versioning"
    Purpose     = "Long-term compliance evidence storage"
  }
}

# Enable encryption for evidence archive
resource "aws_s3_bucket_server_side_encryption_configuration" "evidence_encryption" {
  bucket = aws_s3_bucket.evidence_archive.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.evidence_key.arn
    }
    bucket_key_enabled = true
  }
}

# Enable versioning for evidence integrity
resource "aws_s3_bucket_versioning" "evidence_versioning" {
  bucket = aws_s3_bucket.evidence_archive.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access to evidence
resource "aws_s3_bucket_public_access_block" "evidence_block" {
  bucket = aws_s3_bucket.evidence_archive.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable access logging for evidence audit trail
resource "aws_s3_bucket_logging" "evidence_logging" {
  bucket = aws_s3_bucket.evidence_archive.id

  target_bucket = data.aws_s3_bucket.lab23_data_bucket.id
  target_prefix = "evidence-access-logs/"
}

# ============================================================================
# Evidence Collection Lambda Function
# Triggers: S3 events, scheduled CloudWatch Events
# Purpose: Collect and archive compliance evidence
# ============================================================================

resource "aws_iam_role" "evidence_lambda_role" {
  name = "cgep-evidence-collector-role-${var.lab_identifier}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Basic Lambda execution permissions
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.evidence_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# S3 read permissions for evidence collection
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda-s3-evidence-policy"
  role = aws_iam_role.evidence_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          data.aws_s3_bucket.lab23_data_bucket.arn,
          "${data.aws_s3_bucket.lab23_data_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectVersionTagging"
        ]
        Resource = [
          aws_s3_bucket.evidence_archive.arn,
          "${aws_s3_bucket.evidence_archive.arn}/*"
        ]
      }
    ]
  })
}

# DynamoDB permissions for evidence tracking
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "lambda-dynamodb-evidence-policy"
  role = aws_iam_role.evidence_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.evidence_metadata.arn
      }
    ]
  })
}

# Lambda function for evidence collection
resource "aws_lambda_function" "evidence_collector" {
  filename      = "lambda_function.zip"
  function_name = "cgep-evidence-collector-${var.lab_identifier}"
  role          = aws_iam_role.evidence_lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  environment {
    variables = {
      EVIDENCE_BUCKET    = aws_s3_bucket.evidence_archive.id
      METADATA_TABLE     = aws_dynamodb_table.evidence_metadata.name
      SOURCE_BUCKET      = data.aws_s3_bucket.lab23_data_bucket.id
      COLLECTION_DATE    = formatdate("YYYY-MM-DD", timestamp())
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_s3_policy,
    aws_iam_role_policy.lambda_dynamodb_policy
  ]

  tags = {
    Name        = "Evidence Collector Lambda"
    Control     = "AU-3"
    Description = "Automated evidence collection from S3 bucket"
  }
}

# ============================================================================
# CloudWatch Events: Scheduled Evidence Collection
# Trigger: Daily at 2 AM UTC
# Purpose: Regular automated evidence capture
# ============================================================================

resource "aws_cloudwatch_event_rule" "evidence_collection_schedule" {
  name                = "cgep-evidence-collection-${var.lab_identifier}"
  description         = "Trigger daily evidence collection"
  schedule_expression = "cron(0 2 * * ? *)"  # Daily at 2 AM UTC

  tags = {
    Control = "AU-6"
    Purpose = "Scheduled evidence collection"
  }
}

resource "aws_cloudwatch_event_target" "evidence_lambda" {
  rule      = aws_cloudwatch_event_rule.evidence_collection_schedule.name
  target_id = "EvidenceCollectorLambda"
  arn       = aws_lambda_function.evidence_collector.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.evidence_collector.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.evidence_collection_schedule.arn
}

# ============================================================================
# SNS Topic for Evidence Notifications
# Control: AU-6 - Review and analysis of audit logs
# ============================================================================

resource "aws_sns_topic" "evidence_notifications" {
  name = "cgep-evidence-notifications-${var.lab_identifier}"

  kms_master_key_id = aws_kms_key.evidence_key.id

  tags = {
    Name    = "Evidence Notifications"
    Control = "AU-6"
  }
}

# ============================================================================
# CloudWatch Log Group for Evidence Collection Logs
# Control: AU-3 - Recording of evidence collection activities
# ============================================================================

resource "aws_cloudwatch_log_group" "evidence_collection_logs" {
  name              = "/aws/lambda/cgep-evidence-collector-${var.lab_identifier}"
  retention_in_days = 90

  tags = {
    Name    = "Evidence Collection Logs"
    Control = "AU-3"
  }
}

# ============================================================================
# Evidence Integrity Verification
# Lambda function to verify evidence hash and completeness
# ============================================================================

resource "aws_iam_role" "verification_lambda_role" {
  name = "cgep-evidence-verification-role-${var.lab_identifier}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "verification_lambda_basic" {
  role       = aws_iam_role.verification_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "verification_lambda_s3" {
  name = "verification-s3-policy"
  role = aws_iam_role.verification_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucketVersions"
        ]
        Resource = [
          aws_s3_bucket.evidence_archive.arn,
          "${aws_s3_bucket.evidence_archive.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "evidence_verifier" {
  filename      = "lambda_verify.zip"
  function_name = "cgep-evidence-verifier-${var.lab_identifier}"
  role          = aws_iam_role.verification_lambda_role.arn
  handler       = "verify.lambda_handler"
  runtime       = "python3.11"
  timeout       = 300

  environment {
    variables = {
      EVIDENCE_BUCKET = aws_s3_bucket.evidence_archive.id
      VERIFICATION_ID = var.lab_identifier
    }
  }

  tags = {
    Name    = "Evidence Verifier Lambda"
    Control = "SI-10"
  }
}

# ============================================================================
# Evidence Retention Policy
# Control: SI-10 - Maintain evidence integrity and availability
# ============================================================================

resource "aws_s3_bucket_lifecycle_configuration" "evidence_retention" {
  bucket = aws_s3_bucket.evidence_archive.id

  rule {
    id     = "evidence-retention-policy"
    status = "Enabled"

    filter {}

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 2555  # 7 years for evidence retention
    }
  }
}
