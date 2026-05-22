# NIST SC-28(1): Encryption at Rest
# Ensures all data at rest is encrypted

package main

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    not has_encryption(resource)
    msg := sprintf("FAIL: SC-28(1) - S3 bucket must have encryption enabled: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_dynamodb_table"
    server_side_encryption := resource.change.after.server_side_encryption
    not server_side_encryption[0].enabled
    msg := sprintf("FAIL: SC-28(1) - DynamoDB table must have encryption enabled: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_kms_key"
    enabled := resource.change.after.enable_key_rotation
    not enabled
    msg := sprintf("FAIL: SC-28(1) - KMS key must have rotation enabled: %s", [resource.address])
}

# Helper: Check if S3 bucket has encryption configured
has_encryption(resource) {
    encryption := resource.change.after.server_side_encryption_configuration
    encryption[_].rule[_].apply_server_side_encryption_by_default[_].sse_algorithm
}

# Allow pass if encryption is properly configured
allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    has_encryption(resource)
    msg := sprintf("PASS: SC-28(1) - S3 bucket %s has encryption enabled", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_dynamodb_table"
    server_side_encryption := resource.change.after.server_side_encryption
    server_side_encryption[0].enabled == true
    msg := sprintf("PASS: SC-28(1) - DynamoDB table %s has encryption enabled", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_kms_key"
    resource.change.after.enable_key_rotation == true
    msg := sprintf("PASS: SC-28(1) - KMS key %s has rotation enabled", [resource.address])
}
