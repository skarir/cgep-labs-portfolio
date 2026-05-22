variable "aws_region" {
  description = "AWS region for Lab 2.5 resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "cgep-lab"
}

variable "lab_identifier" {
  description = "Unique identifier for this lab deployment"
  type        = string
  default     = "lab25-evidence"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.lab_identifier))
    error_message = "Lab identifier must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "lab23_data_bucket_name" {
  description = "Name of the S3 bucket created in Lab 2.3"
  type        = string

  validation {
    condition     = can(regex("^cgep-lab-", var.lab23_data_bucket_name))
    error_message = "Must reference a Lab 2.3 bucket (starts with cgep-lab-)"
  }
}

variable "evidence_retention_days" {
  description = "Number of days to retain evidence in DynamoDB (before TTL)"
  type        = number
  default     = 2555  # 7 years

  validation {
    condition     = var.evidence_retention_days >= 1
    error_message = "Evidence retention must be at least 1 day."
  }
}

variable "lambda_timeout" {
  description = "Timeout in seconds for Lambda functions"
  type        = number
  default     = 60

  validation {
    condition     = var.lambda_timeout >= 3 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 3 and 900 seconds."
  }
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB evidence integrity"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}
