variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "enable_control_tower" {
  description = "Flag to enable AWS Control Tower."
  type        = bool
  default     = true
}

variable "master_account_email" {
  description = "Email address for the AWS Control Tower master account."
  type        = string
}

variable "master_account_id" {
  description = "Account ID for the AWS Control Tower master account."
  type        = string
}

variable "organizational_units" {
  description = "List of organizational units to create in AWS Control Tower."
  type        = list(string)
  default     = ["Security", "Audit Log", "Sandbox"]
}

variable "dev_account_email" {
  description = "Email address for the Dev account."
  type        = string
}

variable "prod_account_email" {
  description = "Email address for the Prod account."
  type        = string
}

variable "shared_account_email" {
  description = "Email address for the Shared account."
  type        = string
}

variable "security_account_email" {
  description = "Email address for the Security account."
  type        = string
}

variable "audit_account_email" {
  description = "Email address for the Audit account."
  type        = string
}

variable "aft_logs_bucket_name" {
  description = "Name of the S3 bucket for AFT logs."
  type        = string
  default     = "aft-logs-bucket-863518414447"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}