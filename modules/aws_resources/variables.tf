variable "s3_bucket_name" {
  description = "The name of the S3 bucket for storing AFT logs."
  type        = string
}

variable "kms_key_alias" {
  description = "The alias for the KMS key used for encryption."
  type        = string
  default     = "alias/aft-key"
}

variable "sns_topic_name" {
  description = "The name of the SNS topic for AFT notifications."
  type        = string
  default     = "aft-notifications"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for handling AFT requests."
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for AFT operations."
  type        = string
}

variable "master_account_id" {
  description = "The AWS account ID of the master account."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

variable "log_retention_in_days" {
  description = "The retention period for CloudWatch logs in days."
  type        = number
  default     = 90
}