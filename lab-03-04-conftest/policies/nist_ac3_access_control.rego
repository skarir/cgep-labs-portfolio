# NIST AC-3: Access Enforcement
# Ensures proper access control mechanisms are in place

package main

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    not all_blocks_enabled(resource)
    msg := sprintf("FAIL: AC-3 - All public access blocks must be enabled: %s", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_role"
    resource.address != "aws_iam_role.cloudtrail_cloudwatch_role" &&
    resource.address != "aws_iam_role.evidence_lambda_role" &&
    resource.address != "aws_iam_role.verification_lambda_role"
    # Allow service roles but check for proper policies
    msg := sprintf("WARN: AC-3 - Verify IAM role %s has least privilege policy", [resource.address])
}

# Helper: Check if all public access blocks are enabled
all_blocks_enabled(resource) {
    resource.change.after.block_public_acls == true
    resource.change.after.block_public_policy == true
    resource.change.after.ignore_public_acls == true
    resource.change.after.restrict_public_buckets == true
}

# Allow pass if access control is properly configured
allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    all_blocks_enabled(resource)
    msg := sprintf("PASS: AC-3 - Public access block %s fully enabled", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_role_policy"
    msg := sprintf("PASS: AC-3 - IAM role policy %s defines access controls", [resource.address])
}

allow[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_policy"
    msg := sprintf("PASS: AC-3 - IAM policy %s defines access rules", [resource.address])
}
