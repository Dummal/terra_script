```hcl
# main.tf
# This Terraform script sets up an AWS Control Tower environment with organizational units and accounts.
# Assumptions: The user will provide the required inputs via variables.

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  # AWS region is passed as a variable
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1" # Default region if not provided
}

variable "master_account_email" {
  description = "Email address associated with the master account."
  type        = string
}

variable "master_account_id" {
  description = "Master account ID used in this AWS setup."
  type        = string
}

variable "development_account_email" {
  description = "Email assigned to the development account."
  type        = string
}

variable "production_account_email" {
  description = "Email used for the production account."
  type        = string
}

variable "shared_account_email" {
  description = "Email associated with the shared account."
  type        = string
}

variable "security_account_email" {
  description = "Security account email configured in this setup."
  type        = string
}

variable "audit_account_email" {
  description = "Email used for the audit account."
  type        = string
}

variable "aft_logs_bucket_name" {
  description = "Name of the S3 bucket for AFT logs."
  type        = string
}

variable "organizational_units" {
  description = "List of organizational units in this AWS setup."
  type        = list(string)
  default     = ["Security", "Audit Log", "Sandbox"] # Default OUs
}

# AWS Organizations Setup
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

# Organizational Units
resource "aws_organizations_organizational_unit" "ou" {
  for_each = toset(var.organizational_units)

  name      = each.value
  parent_id = aws_organizations_organization.org.id
}

# Example: S3 Bucket for AFT Logs
resource "aws_s3_bucket" "aft_logs" {
  bucket = var.aft_logs_bucket_name

  tags = {
    Name        = "AFT Logs Bucket"
    Environment = "Production"
  }
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = aws_organizations_organization.org.id
}

output "organizational_units" {
  description = "List of created organizational units."
  value       = [for ou in aws_organizations_organizational_unit.ou : ou.name]
}

output "aft_logs_bucket_name" {
  description = "The name of the S3 bucket for AFT logs."
  value       = aws_s3_bucket.aft_logs.bucket
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file to define the variables or pass them via CLI.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Notes:
- Replace the default values in the `variables.tf` file or pass them as CLI arguments.
- Ensure the AWS credentials are configured in your environment before running the script.
- This script assumes AWS Control Tower is enabled and organizational units are being managed.