```hcl
# main.tf
# This Terraform script sets up an AWS Landing Zone with AWS Organizations and centralized logging.
# Assumptions:
# - Multi-region support is not required.
# - AWS CloudTrail logging is not enabled.
# - Centralized logging is enabled for all accounts.
# - The organization name and email are provided as variables.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# Create an AWS Organization
resource "aws_organizations_organization" "main" {
  feature_set = "ALL"

  tags = {
    Name        = var.organization_name
    Environment = var.environment
  }
}

# Create a logging account
module "logging_account" {
  source = "./modules/account"

  account_name  = "LoggingAccount"
  email         = var.logging_account_email
  organization_id = aws_organizations_organization.main.id
  tags = {
    Name        = "LoggingAccount"
    Environment = var.environment
  }
}

# Centralized logging bucket in the logging account
module "logging_bucket" {
  source = "./modules/s3_bucket"

  bucket_name = "centralized-logs-${var.environment}"
  tags = {
    Name        = "CentralizedLogs"
    Environment = var.environment
  }
}

# Outputs
output "organization_id" {
  value       = aws_organizations_organization.main.id
  description = "The ID of the AWS Organization."
}

output "logging_account_id" {
  value       = module.logging_account.account_id
  description = "The ID of the logging account."
}

output "logging_bucket_name" {
  value       = module.logging_bucket.bucket_name
  description = "The name of the centralized logging bucket."
}

# variables.tf
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "organization_name" {
  description = "The name of the AWS Organization."
  type        = string
}

variable "environment" {
  description = "The environment for the resources (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "logging_account_email" {
  description = "The email address for the logging account."
  type        = string
}

# modules/account/main.tf
resource "aws_organizations_account" "account" {
  name      = var.account_name
  email     = var.email
  role_name = "OrganizationAccountAccessRole"

  tags = var.tags
}

output "account_id" {
  value       = aws_organizations_account.account.id
  description = "The ID of the created account."
}

# modules/account/variables.tf
variable "account_name" {
  description = "The name of the AWS account."
  type        = string
}

variable "email" {
  description = "The email address for the AWS account."
  type        = string
}

variable "organization_id" {
  description = "The ID of the AWS Organization."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the account."
  type        = map(string)
}

# modules/s3_bucket/main.tf
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

output "bucket_name" {
  value       = aws_s3_bucket.bucket.id
  description = "The name of the S3 bucket."
}

# modules/s3_bucket/variables.tf
variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the S3 bucket."
  type        = map(string)
}
```

### Instructions to Apply:
1. Save the script in a file structure as follows:
   ```
   .
   ├── main.tf
   ├── variables.tf
   ├── modules
       ├── account
       │   ├── main.tf
       │   ├── variables.tf
       ├── s3_bucket
           ├── main.tf
           ├── variables.tf
   ```
2. Replace the placeholder values in `terraform.tfvars` or pass them as CLI arguments:
   ```hcl
   organization_name = "hdgjhshdghjsgjd"
   logging_account_email = "dsdnsvnbdvsnbd"
   ```
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.