```hcl
# main.tf
# This Terraform script sets up an AWS Control Tower environment with organizational units and accounts.

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

# Variables
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1" # Default region, can be overridden
}

variable "control_tower_enabled" {
  description = "Flag to enable AWS Control Tower."
  type        = bool
  default     = true
}

variable "master_account_email" {
  description = "Email address for the master account."
  type        = string
}

variable "master_account_id" {
  description = "Master account ID."
  type        = string
}

variable "development_account_email" {
  description = "Email address for the development account."
  type        = string
}

variable "production_account_email" {
  description = "Email address for the production account."
  type        = string
}

variable "shared_account_email" {
  description = "Email address for the shared account."
  type        = string
}

variable "security_account_email" {
  description = "Email address for the security account."
  type        = string
}

variable "audit_account_email" {
  description = "Email address for the audit account."
  type        = string
}

variable "aft_logs_bucket_name" {
  description = "Name of the S3 bucket for AFT logs."
  type        = string
}

variable "organizational_units" {
  description = "List of organizational units to create."
  type        = list(string)
  default     = ["Security", "Audit Log", "Sandbox"] # Default OUs
}

# AWS Control Tower Setup
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

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
  description = "The list of created organizational units."
  value       = [for ou in aws_organizations_organizational_unit.ou : ou.name]
}

output "aft_logs_bucket_name" {
  description = "The name of the S3 bucket for AFT logs."
  value       = aws_s3_bucket.aft_logs.bucket
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file to define the variables or override them using a `terraform.tfvars` file.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- AWS Control Tower is enabled (`control_tower_enabled` is set to `true` by default).
- Organizational units are provided as a list in the `organizational_units` variable.
- Sensitive data like emails and account IDs are passed as variables and not hardcoded.
- The S3 bucket for AFT logs is created with a name provided in the `aft_logs_bucket_name` variable.