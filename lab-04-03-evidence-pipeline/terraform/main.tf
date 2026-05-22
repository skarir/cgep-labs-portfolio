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
      Project     = "CGE-P-Lab-4.3"
      ManagedBy   = "Terraform"
      Compliance  = "NIST-800-53"
      Controls    = "AU-6 AU-3 CA-7 SI-4"
    }
  }
}

# ============================================================================
# Lab 4.3: GRC Evidence Pipeline
# Description: Governance, Risk & Compliance automation platform
# Controls: AU-6, AU-3, CA-7, SI-4
# ============================================================================

# ============================================================================
# DynamoDB: Control Status Tracking Table
# Purpose: Central store for control compliance status
# ============================================================================

resource "aws_dynamodb_table" "grc_control_status" {
  name           = "grc-control-status-${var.lab_identifier}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ControlID"
  range_key      = "Timestamp"

  attribute {
    name = "ControlID"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "S"
  }

  # GSI for querying by Status
  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "Status"
    range_key       = "Timestamp"
    projection_type = "ALL"
  }

  # GSI for querying by Framework
  global_secondary_index {
    name            = "FrameworkIndex"
    hash_key        = "Framework"
    range_key       = "Timestamp"
    projection_type = "ALL"
  }

  attribute {
    name = "Status"
    type = "S"
  }

  attribute {
    name = "Framework"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name    = "GRC Control Status"
    Control = "CA-7"
  }
}

# ============================================================================
# SNS Topic: Compliance Notifications
# Purpose: Alert on compliance status changes
# ============================================================================

resource "aws_sns_topic" "compliance_notifications" {
  name = "cgep-grc-compliance-${var.lab_identifier}"

  tags = {
    Name    = "Compliance Notifications"
    Control = "AU-6"
  }
}

resource "aws_sns_topic_subscription" "compliance_email" {
  topic_arn = aws_sns_topic.compliance_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email

  # Auto-confirm is false - user must confirm via email
}

# ============================================================================
# Lambda: Evidence Aggregator & Compliance Scorer
# Purpose: Aggregate evidence, validate policies, calculate compliance score
# ============================================================================

resource "aws_iam_role" "grc_lambda_role" {
  name = "cgep-grc-lambda-role-${var.lab_identifier}"

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

resource "aws_iam_role_policy_attachment" "grc_lambda_basic" {
  role       = aws_iam_role.grc_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "grc_lambda_policy" {
  name = "cgep-grc-lambda-policy"
  role = aws_iam_role.grc_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:GetItem"
        ]
        Resource = [
          aws_dynamodb_table.grc_control_status.arn,
          "${aws_dynamodb_table.grc_control_status.arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::cgep-evidence-archive-*",
          "arn:aws:s3:::cgep-evidence-archive-*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.compliance_notifications.arn
      }
    ]
  })
}

resource "aws_lambda_function" "evidence_aggregator" {
  filename      = "lambda_grc_aggregator.zip"
  function_name = "cgep-grc-evidence-aggregator-${var.lab_identifier}"
  role          = aws_iam_role.grc_lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"
  timeout       = 300

  environment {
    variables = {
      CONTROL_STATUS_TABLE = aws_dynamodb_table.grc_control_status.name
      SNS_TOPIC_ARN        = aws_sns_topic.compliance_notifications.arn
    }
  }

  source_code_hash = filebase64sha256("lambda_grc_aggregator.zip")

  tags = {
    Name    = "GRC Evidence Aggregator"
    Control = "CA-7"
  }
}

# ============================================================================
# EventBridge: Compliance Pipeline Orchestration
# Purpose: Schedule and coordinate evidence collection, validation, scoring
# ============================================================================

resource "aws_cloudwatch_event_rule" "grc_daily_pipeline" {
  name                = "cgep-grc-daily-pipeline-${var.lab_identifier}"
  description         = "Trigger daily GRC evidence pipeline"
  schedule_expression = "cron(30 2 * * ? *)"  # Daily at 2:30 AM UTC

  tags = {
    Control = "AU-6"
  }
}

resource "aws_cloudwatch_event_target" "grc_pipeline_lambda" {
  rule      = aws_cloudwatch_event_rule.grc_daily_pipeline.name
  target_id = "GRCEvidenceAggregator"
  arn       = aws_lambda_function.evidence_aggregator.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.evidence_aggregator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.grc_daily_pipeline.arn
}

# ============================================================================
# CloudWatch Dashboard: Compliance Metrics
# Purpose: Real-time visibility into compliance status
# ============================================================================

resource "aws_cloudwatch_dashboard" "grc_compliance" {
  dashboard_name = "cgep-grc-compliance-${var.lab_identifier}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", { stat = "Sum" }],
            ["...", "ConsumedReadCapacityUnits", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "GRC Database Activity"
        }
      },
      {
        type = "log"
        properties = {
          query   = "fields @timestamp, @message | filter @message like /COMPLIANCE/ | stats count() by @message"
          region  = var.aws_region
          title   = "Compliance Events"
        }
      }
    ]
  })
}

# ============================================================================
# CloudWatch Log Group: GRC Pipeline Logs
# Purpose: Audit trail for evidence aggregation and compliance scoring
# ============================================================================

resource "aws_cloudwatch_log_group" "grc_logs" {
  name              = "/aws/lambda/cgep-grc-${var.lab_identifier}"
  retention_in_days = 90

  tags = {
    Name    = "GRC Pipeline Logs"
    Control = "AU-3"
  }
}

# ============================================================================
# Summary Output
# ============================================================================

output "lab43_compliance_summary" {
  value = {
    framework             = "NIST 800-53"
    assessment_status     = "DEPLOYED"
    controls_implemented  = 4
    controls_list = [
      "AU-6",
      "AU-3",
      "CA-7",
      "SI-4"
    ]
    control_tracking      = "✓ DynamoDB control status table"
    evidence_aggregation  = "✓ Lambda evidence aggregator"
    compliance_scoring    = "✓ Automated compliance score calculation"
    pipeline_orchestration = "✓ EventBridge daily schedule (2:30 AM UTC)"
    compliance_reporting  = "✓ SNS notifications on status changes"
    dashboard_monitoring  = "✓ CloudWatch compliance metrics"
  }

  description = "Lab 4.3 GRC Evidence Pipeline - Governance, Risk & Compliance Automation"
}
