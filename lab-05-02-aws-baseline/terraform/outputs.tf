output "cloudtrail" {
  value = {
    name                   = aws_cloudtrail.baseline.name
    s3_bucket              = aws_s3_bucket.cloudtrail_logs.id
    is_multi_region        = aws_cloudtrail.baseline.is_multi_region_trail
    log_file_validation    = aws_cloudtrail.baseline.enable_log_file_validation
    cloudwatch_log_group   = aws_cloudwatch_log_group.cloudtrail_logs.name
    control                = "AU-2, AU-6"
  }
  description = "CloudTrail configuration for API audit logging"
}

output "config" {
  value = {
    recorder_name          = aws_config_configuration_recorder.baseline.name
    s3_bucket              = aws_s3_bucket.config_bucket.id
    snapshot_frequency     = "Six_Hours"
    rules_count            = 0
    rules_implemented      = []
    status                 = "Configured (Delivery channel requires advanced setup)"
    control                = "CA-7"
  }
  description = "AWS Config for continuous compliance monitoring (base configuration)"
}

output "guardduty" {
  value = {
    detector_id            = aws_guardduty_detector.baseline.id
    enabled                = aws_guardduty_detector.baseline.enable
    s3_logs_enabled        = aws_guardduty_detector.baseline.datasources[0].s3_logs[0].enable
    kubernetes_audit_logs  = aws_guardduty_detector.baseline.datasources[0].kubernetes[0].audit_logs[0].enable
    control                = "SI-4"
  }
  description = "GuardDuty threat detection configuration"
}

output "iam_security" {
  value = {
    password_policy = {
      minimum_length   = aws_iam_account_password_policy.baseline.minimum_password_length
      require_symbols  = aws_iam_account_password_policy.baseline.require_symbols
      require_uppercase = aws_iam_account_password_policy.baseline.require_uppercase_characters
      require_lowercase = aws_iam_account_password_policy.baseline.require_lowercase_characters
      require_numbers  = aws_iam_account_password_policy.baseline.require_numbers
      password_reuse_prevention = aws_iam_account_password_policy.baseline.password_reuse_prevention
      max_password_age = aws_iam_account_password_policy.baseline.max_password_age
    }
    least_privilege_policy = aws_iam_policy.least_privilege_s3_read.arn
    controls               = "AC-2, AC-6, IA-2"
  }
  description = "IAM password policy and least privilege configuration"
}

output "vpc_flow_logs" {
  value = {
    log_group              = aws_cloudwatch_log_group.vpc_flow_logs.name
    traffic_type           = aws_flow_log.default_vpc.traffic_type
    vpc_id                 = aws_flow_log.default_vpc.vpc_id
    retention_days         = aws_cloudwatch_log_group.vpc_flow_logs.retention_in_days
    control                = "SC-7"
  }
  description = "VPC Flow Logs configuration for network monitoring"
}

output "secrets_manager" {
  value = {
    secret_id              = aws_secretsmanager_secret.api_key_secret.id
    secret_arn             = aws_secretsmanager_secret.api_key_secret.arn
    recovery_window_days   = aws_secretsmanager_secret.api_key_secret.recovery_window_in_days
    control                = "SC-28"
  }
  description = "Secrets Manager configuration for credential protection"
}

output "lab52_summary" {
  value = {
    status                 = "DEPLOYED"
    total_controls         = 8
    framework              = "NIST 800-53"
    services_configured = [
      "CloudTrail",
      "AWS Config",
      "GuardDuty",
      "CloudWatch",
      "IAM",
      "VPC Flow Logs",
      "Secrets Manager"
    ]
  }
  description = "Lab 5.2 AWS Security Baseline deployment summary"
}
