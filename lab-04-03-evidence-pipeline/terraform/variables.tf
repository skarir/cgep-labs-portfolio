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
  default     = "lab43-grc"
}

variable "notification_email" {
  description = "Email address for compliance notifications"
  type        = string
  default     = "sunil.karir@gmail.com"
}
