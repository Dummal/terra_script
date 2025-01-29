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
  description = "Email address for the master account."
  type        = string
}

variable "master_account_id" {
  description = "AWS account ID for the master account."
  type        = string
}

variable "organizational_units" {
  description = "List of organizational units to create."
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

variable "kms_key_rotation_enabled" {
  description = "Flag to enable KMS key rotation."
  type        = bool
  default     = true
}

variable "sns_topic_name" {
  description = "Name of the SNS topic for notifications."
  type        = string
  default     = "aft-notifications"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for AFT requests."
  type        = string
  default     = "aft-requests"
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for AFT logs."
  type        = string
  default     = "/aws/aft/logs"
}

variable "cloudwatch_log_retention_days" {
  description = "Retention period for CloudWatch logs in days."
  type        = number
  default     = 90
}

variable "resource_tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}