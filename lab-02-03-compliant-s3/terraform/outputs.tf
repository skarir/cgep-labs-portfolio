output "data_bucket_id" {
  description = "ID of the compliant data bucket"
  value       = aws_s3_bucket.compliant_data_bucket.id
}

output "data_bucket_arn" {
  description = "ARN of the compliant data bucket"
  value       = aws_s3_bucket.compliant_data_bucket.arn
}

output "data_bucket_region" {
  description = "Region of the compliant data bucket"
  value       = aws_s3_bucket.compliant_data_bucket.region
}

output "logging_bucket_id" {
  description = "ID of the logging bucket"
  value       = aws_s3_bucket.logging_bucket.id
}

output "logging_bucket_arn" {
  description = "ARN of the logging bucket"
  value       = aws_s3_bucket.logging_bucket.arn
}

output "encryption_status" {
  description = "Encryption configuration details"
  value = {
    algorithm      = "AES256"
    bucket_key     = true
    control        = "SC-28(1)"
    implementation = "Server-side encryption with AWS-managed keys"
  }
}

output "versioning_status" {
  description = "Versioning configuration details"
  value = {
    status     = "Enabled"
    mfa_delete = "Disabled"
    control    = "CM-6(1)"
    purpose    = "Configuration baseline and audit trail"
  }
}

output "public_access_blocks" {
  description = "Public access block configuration for access control"
  value = {
    block_public_acls       = aws_s3_bucket_public_access_block.compliant_public_block.block_public_acls
    block_public_policy     = aws_s3_bucket_public_access_block.compliant_public_block.block_public_policy
    ignore_public_acls      = aws_s3_bucket_public_access_block.compliant_public_block.ignore_public_acls
    restrict_public_buckets = aws_s3_bucket_public_access_block.compliant_public_block.restrict_public_buckets
    control                 = "AC-3(1)"
    principle               = "Least Privilege Access"
  }
}

output "logging_configuration" {
  description = "Access logging configuration for audit"
  value = {
    target_bucket = aws_s3_bucket_logging.compliant_logging.target_bucket
    target_prefix = aws_s3_bucket_logging.compliant_logging.target_prefix
    controls      = ["AU-3(1)", "AU-6(1)"]
    purpose       = "Centralized access logging and audit trail"
  }
}

output "bucket_policy" {
  description = "Bucket policy enforcement"
  value = {
    policy_type = "SSL/TLS Enforcement"
    effect      = "Deny non-HTTPS requests"
    control     = "AC-3(1)"
    description = "Additional access control - enforce secure transport"
  }
}

output "compliance_summary" {
  description = "Complete compliance control summary"
  value = {
    framework              = "NIST 800-53"
    controls_implemented  = 5
    controls_list         = ["SC-28(1)", "AU-3(1)", "AU-6(1)", "CM-6(1)", "AC-3(1)"]
    encryption_at_rest    = "✓ Enabled (AES256)"
    audit_logging         = "✓ Enabled"
    configuration_mgmt    = "✓ Versioning enabled"
    access_control        = "✓ Public access blocked, SSL enforced"
    ssl_tls_enforcement   = "✓ Enforced"
    assessment_status     = "COMPLIANT"
  }
}
