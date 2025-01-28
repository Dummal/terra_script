variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2"
}

variable "master_account_email" {
  description = "Email address for the master account."
  type        = string
}

variable "master_account_id" {
  description = "AWS Account ID for the master account."
  type        = string
}

variable "organizational_units" {
  description = "List of Organizational Units (OUs) to create."
  type        = list(string)
  default     = ["Security", "Audit Log"]
}

variable "aft_logs_bucket_name" {
  description = "Name of the S3 bucket for AFT logs."
  type        = string
}