# NIST AU-3: Audit Events (Logging)
# Ensures audit records contain necessary information

package main

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not has_logging(resource)
    msg := sprintf("FAIL: AU-3 - S3 bucket must have access logging: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_cloudtrail"
    not resource.change.after.enable_log_file_validation
    msg := sprintf("FAIL: AU-3 - CloudTrail must have log file validation enabled: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_cloudwatch_log_group"
    not has_log_retention(resource)
    msg := sprintf("FAIL: AU-3 - CloudWatch log group must have retention policy: %s", [resource.address])
}

# Helper: Check if S3 bucket has logging configured
has_logging(resource) {
    logging := resource.change.after.logging
    logging[_].target_bucket
}

# Helper: Check if log group has retention configured
has_log_retention(resource) {
    retention := resource.change.after.retention_in_days
    retention > 0
}

# Allow pass if logging is properly configured
allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    has_logging(resource)
    msg := sprintf("PASS: AU-3 - S3 bucket %s has access logging enabled", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_cloudtrail"
    resource.change.after.enable_log_file_validation == true
    msg := sprintf("PASS: AU-3 - CloudTrail %s has log file validation enabled", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_cloudwatch_log_group"
    has_log_retention(resource)
    msg := sprintf("PASS: AU-3 - CloudWatch log group %s has retention policy", [resource.address])
}
