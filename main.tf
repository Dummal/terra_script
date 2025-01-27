```hcl
# main.tf
# This Terraform script sets up an AWS Organization with centralized logging.
# Assumptions:
# - AWS Organizations is enabled.
# - Centralized logging is required.
# - CloudTrail logging is not enabled as per user input.

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create an AWS Organization
resource "aws_organizations_organization" "main" {
  feature_set = "ALL"

  # Tags for resource identification
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# Create a logging account in the organization
resource "aws_organizations_account" "logging_account" {
  name      = var.logging_account_name
  email     = var.logging_account_email
  role_name = var.logging_account_role_name

  # Tags for resource identification
  tags = {
    Project     = var.project_name
    Environment = var.environment
    AccountType = "Logging"
  }
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.main.id
}

output "logging_account_id" {
  description = "The ID of the logging account"
  value       = aws_organizations_account.logging_account.id
}

# variables.tf
# Define variables for the script
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project or organization"
  type        = string
  default     = "Hello" # Default value based on user input
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, prod)"
  type        = string
  default     = "production"
}

variable "logging_account_name" {
  description = "The name of the logging account"
  type        = string
  default     = "LoggingAccount"
}

variable "logging_account_email" {
  description = "The email address for the logging account"
  type        = string
  default     = "hello.world@example.com" # Default value based on user input
}

variable "logging_account_role_name" {
  description = "The IAM role name for the logging account"
  type        = string
  default     = "OrganizationAccountAccessRole"
}

# outputs.tf
# Outputs are already defined in the main.tf file for simplicity.

# Instructions to Apply:
# 1. Save the script in a file, e.g., `main.tf`.
# 2. Initialize Terraform: `terraform init`.
# 3. Review the plan: `terraform plan`.
# 4. Apply the configuration: `terraform apply`.
# 5. Confirm the changes when prompted.
```