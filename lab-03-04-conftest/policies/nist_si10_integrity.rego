# NIST SI-10: Evidence Integrity and Confidentiality
# Ensures evidence and audit data integrity

package main

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.address contains "evidence"
    not has_encryption(resource)
    msg := sprintf("FAIL: SI-10 - Evidence bucket must have encryption: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.address contains "evidence"
    not has_versioning_configured(resource)
    msg := sprintf("FAIL: SI-10 - Evidence bucket must have versioning: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_dynamodb_table"
    resource.address contains "evidence"
    point_in_time := resource.change.after.point_in_time_recovery
    not point_in_time[0].enabled
    msg := sprintf("FAIL: SI-10 - Evidence table must have PITR: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_dynamodb_table"
    server_side_encryption := resource.change.after.server_side_encryption
    not server_side_encryption[0].enabled
    msg := sprintf("FAIL: SI-10 - DynamoDB table must be encrypted: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_lambda_function"
    resource.address contains "verif"
    not has_timeout(resource)
    msg := sprintf("FAIL: SI-10 - Evidence verification Lambda must have timeout: %s", [resource.address])
}

# Helpers
has_encryption(resource) {
    encryption := resource.change.after.server_side_encryption_configuration
    encryption[_].rule[_].apply_server_side_encryption_by_default[_].sse_algorithm
}

has_versioning_configured(resource) {
    versioning := resource.change.after.versioning
    versioning[_].status == "Enabled"
}

has_timeout(resource) {
    timeout := resource.change.after.timeout
    timeout > 0
}

# Allow passes
allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket"
    resource.address contains "evidence"
    has_encryption(resource)
    msg := sprintf("PASS: SI-10 - Evidence bucket %s is encrypted", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_dynamodb_table"
    point_in_time := resource.change.after.point_in_time_recovery
    point_in_time[0].enabled == true
    msg := sprintf("PASS: SI-10 - DynamoDB table %s has PITR for evidence recovery", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_lambda_function"
    resource.address contains "verif"
    has_timeout(resource)
    msg := sprintf("PASS: SI-10 - Evidence verification Lambda %s has timeout protection", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    msg := sprintf("PASS: SI-10 - Public access blocked for %s", [resource.address])
}
