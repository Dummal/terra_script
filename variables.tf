variable "enable_control_tower" {
  description = "Flag to enable AWS Control Tower if not already enabled"
  type        = bool
  default     = true
}

variable "master_account_email" {
  description = "Email address for the master account"
  type        = string
}

variable "organizational_units" {
  description = "List of organizational units to create"
  type        = list(string)
  default     = ["Security", "Audit Log"]
}

variable "aws_region" {
  description = "The AWS region to deploy the Control Tower landing zone"
  type        = string
}

    