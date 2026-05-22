variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "cgep-lab"

  validation {
    condition     = contains(["cgep-lab", "dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: cgep-lab, dev, test, prod"
  }
}

variable "data_bucket_name" {
  description = "Name of the compliant data bucket (must be globally unique)"
  type        = string
  default     = "cgep-lab-compliant-data-sunil-2026"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.data_bucket_name))
    error_message = "Bucket name must start with lowercase letter/number, contain only lowercase letters/numbers/hyphens, and end with letter/number"
  }
}

variable "logging_bucket_name" {
  description = "Name of the logging bucket (must be globally unique)"
  type        = string
  default     = "cgep-lab-logs-sunil-2026"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.logging_bucket_name))
    error_message = "Bucket name must follow S3 naming conventions"
  }
}

variable "enable_mfa_delete" {
  description = "Enable MFA delete protection (requires MFA device)"
  type        = bool
  default     = false
}
