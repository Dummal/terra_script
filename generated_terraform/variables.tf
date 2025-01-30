variable "aws_region" {
  description = "The AWS region to use for the provider."
  type        = string
  default     = "us-east-1"
}

variable "organization_name" {
  description = "The name of the AWS Organization."
  type        = string
}

variable "parent_id" {
  description = "The parent ID of the AWS Organization (e.g., root ID)."
  type        = string
}

variable "dev_account_email" {
  description = "The email address for the development account."
  type        = string
}

variable "prod_account_email" {
  description = "The email address for the production account."
  type        = string
}

variable "security_account_email" {
  description = "The email address for the security account."
  type        = string
}

variable "audit_account_email" {
  description = "The email address for the audit account."
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources."
  type        = map(string)
  default     = {
    Environment = "Managed by Terraform"
    Project     = "AWS Organization Setup"
  }

variable "organization_name" {
  description = "The name of the AWS Organization."
  type        = string
}

variable "parent_id" {
  description = "The parent ID of the AWS Organization (e.g., root ID)."
  type        = string
}

variable "accounts" {
  description = "A map of accounts to create, with email and name."
  type = map(object({
    email = string
    name  = string
  }

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
}