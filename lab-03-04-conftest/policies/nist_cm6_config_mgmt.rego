# NIST CM-6: Configuration Settings
# Ensures infrastructure configuration is properly managed and controlled

package main

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_versioning"
    not has_versioning(resource)
    msg := sprintf("FAIL: CM-6 - S3 bucket versioning must be enabled: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_cloudtrail"
    not resource.change.after.is_multi_region_trail
    msg := sprintf("FAIL: CM-6 - CloudTrail must be multi-region: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_dynamodb_table"
    point_in_time := resource.change.after.point_in_time_recovery
    not point_in_time[0].enabled
    msg := sprintf("FAIL: CM-6 - DynamoDB PITR must be enabled: %s", [resource.address])
}

# Helper: Check if S3 versioning is enabled
has_versioning(resource) {
    versioning := resource.change.after.versioning_configuration
    versioning[0].status == "Enabled"
}

# Allow pass if configuration management is proper
allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_versioning"
    has_versioning(resource)
    msg := sprintf("PASS: CM-6 - S3 bucket %s has versioning enabled", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_cloudtrail"
    resource.change.after.is_multi_region_trail == true
    msg := sprintf("PASS: CM-6 - CloudTrail %s is multi-region", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_dynamodb_table"
    point_in_time := resource.change.after.point_in_time_recovery
    point_in_time[0].enabled == true
    msg := sprintf("PASS: CM-6 - DynamoDB table %s has PITR enabled", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_lifecycle_configuration"
    msg := sprintf("PASS: CM-6 - S3 bucket %s has lifecycle configuration", [resource.address])
}
