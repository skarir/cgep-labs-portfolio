variable "aws_region" {
  description = "AWS region for resource deployment"
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
  default     = "lab52-baseline"
}

variable "cloudtrail_retention_days" {
  description = "Number of days to retain CloudTrail logs"
  type        = number
  default     = 90
}

variable "config_snapshot_frequency" {
  description = "Frequency of Config snapshots"
  type        = string
  default     = "Six_Hours"
}

variable "vpc_flow_log_retention" {
  description = "VPC Flow Logs retention in days"
  type        = number
  default     = 30
}

variable "secret_recovery_window" {
  description = "Recovery window for secrets in days"
  type        = number
  default     = 7
}
