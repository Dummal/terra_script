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
  description = "The email address for the master account."
  type        = string
}

variable "master_account_id" {
  description = "The AWS account ID of the master account."
  type        = string
}

variable "organizational_units" {
  description = "A map of Organizational Units to create."
  type = map(object({
    name = string
    tags = map(string)
  }

variable "aft_logs_bucket_name" {
  description = "The name of the S3 bucket for AFT logs."
  type        = string
}

variable "global_tags" {
  description = "Global tags to apply to all resources."
  type        = map(string)
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }