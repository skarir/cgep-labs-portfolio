output "evidence_archive_bucket" {
  description = "S3 bucket for evidence archive storage"
  value = {
    bucket_id     = aws_s3_bucket.evidence_archive.id
    bucket_arn    = aws_s3_bucket.evidence_archive.arn
    encryption    = "KMS (${aws_kms_key.evidence_key.id})"
    versioning    = "Enabled"
    control       = "SC-28(1)"
  }
}

output "evidence_metadata_table" {
  description = "DynamoDB table for evidence metadata tracking"
  value = {
    table_name  = aws_dynamodb_table.evidence_metadata.name
    table_arn   = aws_dynamodb_table.evidence_metadata.arn
    encryption  = "KMS"
    pitr        = "Enabled"
    control     = "SI-10"
    indexes     = ["ControlIDIndex"]
  }
}

output "evidence_collector_lambda" {
  description = "Lambda function for evidence collection"
  value = {
    function_name = aws_lambda_function.evidence_collector.function_name
    function_arn  = aws_lambda_function.evidence_collector.arn
    runtime       = aws_lambda_function.evidence_collector.runtime
    timeout       = aws_lambda_function.evidence_collector.timeout
    role          = aws_iam_role.evidence_lambda_role.arn
    control       = "AU-3"
  }
}

output "evidence_verifier_lambda" {
  description = "Lambda function for evidence integrity verification"
  value = {
    function_name = aws_lambda_function.evidence_verifier.function_name
    function_arn  = aws_lambda_function.evidence_verifier.arn
    control       = "SI-10"
    purpose       = "Verify evidence integrity and completeness"
  }
}

output "scheduled_collection" {
  description = "CloudWatch Events schedule for evidence collection"
  value = {
    rule_name      = aws_cloudwatch_event_rule.evidence_collection_schedule.name
    schedule       = aws_cloudwatch_event_rule.evidence_collection_schedule.schedule_expression
    control        = "AU-6"
    frequency      = "Daily at 2 AM UTC"
  }
}

output "encryption_key" {
  description = "KMS key for evidence encryption"
  value = {
    key_id          = aws_kms_key.evidence_key.id
    key_arn         = aws_kms_key.evidence_key.arn
    key_rotation    = "Enabled"
    control         = "SC-28(1)"
  }
}

output "log_group" {
  description = "CloudWatch log group for evidence collection activities"
  value = {
    log_group_name  = aws_cloudwatch_log_group.evidence_collection_logs.name
    retention_days  = aws_cloudwatch_log_group.evidence_collection_logs.retention_in_days
    encryption      = "KMS"
    control         = "AU-3"
  }
}

output "sns_topic" {
  description = "SNS topic for evidence notifications"
  value = {
    topic_arn       = aws_sns_topic.evidence_notifications.arn
    encryption      = "KMS"
    control         = "AU-6"
    purpose         = "Evidence collection notifications and alerts"
  }
}

output "lab25_compliance_summary" {
  description = "Complete Lab 2.5 compliance summary"
  value = {
    framework              = "NIST 800-53"
    controls_implemented  = 4
    controls_list         = ["SC-28(1)", "AU-3", "AU-6", "SI-10"]
    evidence_encryption   = "✓ KMS encryption at rest"
    evidence_versioning   = "✓ S3 versioning enabled"
    evidence_integrity    = "✓ DynamoDB PITR enabled"
    evidence_collection   = "✓ Automated daily collection"
    evidence_verification = "✓ Lambda integrity checker"
    evidence_retention    = "✓ 7-year archive policy"
    assessment_status     = "COMPLIANT"
  }
}
