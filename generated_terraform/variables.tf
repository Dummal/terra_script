variable "organization_parent_id" {
  description = "The parent ID of the AWS Organization"
  type        = string
  default     = "r-1p5x" # Default value based on the provided input
}

variable "dev_account_email" {
  description = "Email address for the Development account"
  type        = string
}

variable "prod_account_email" {
  description = "Email address for the Production account"
  type        = string
}

variable "security_account_email" {
  description = "Email address for the Security account"
  type        = string
}

variable "audit_account_email" {
  description = "Email address for the Audit account"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Organization = "Genworx Organization"
    Environment  = "Production"
  }

variable "account_name" {
  description = "The name of the AWS account"
  type        = string
}

variable "email" {
  description = "The email address associated with the AWS account"
  type        = string
}

variable "parent_id" {
  description = "The parent ID under which the account will be created"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the AWS account"
  type        = map(string)
}