```hcl
# main.tf
# This Terraform script sets up an AWS Control Tower environment with organizational units and accounts.
# Assumptions:
# - AWS region is not specified, so defaulting to "us-east-1".
# - Emails and account details are placeholders and should be replaced with actual values.
# - Organizational units are predefined as "Security", "Audit Log", and "Sandbox".

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
  default     = "us-east-1"
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
  default     = ["Security", "Audit Log", "Sandbox"]
}

# AWS Organizations Setup
module "aws_organizations" {
  source = "./modules/aws_organizations"

  master_account_email       = var.master_account_email
  master_account_id          = var.master_account_id
  development_account_email  = var.development_account_email
  production_account_email   = var.production_account_email
  shared_account_email       = var.shared_account_email
  security_account_email     = var.security_account_email
  audit_account_email        = var.audit_account_email
  organizational_units       = var.organizational_units
}

# S3 Bucket for AFT Logs
resource "aws_s3_bucket" "aft_logs" {
  bucket = var.aft_logs_bucket_name

  tags = {
    Name        = "AFT Logs Bucket"
    Environment = "Production"
  }
}

# Outputs
output "aft_logs_bucket_name" {
  description = "The name of the S3 bucket for AFT logs."
  value       = aws_s3_bucket.aft_logs.bucket
}

output "organizational_units" {
  description = "List of organizational units created in AWS Organizations."
  value       = var.organizational_units
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `modules/aws_organizations` directory and define the module for AWS Organizations setup.
3. Replace placeholder values in the `terraform.tfvars` file or pass them as variables during execution.
4. Initialize Terraform: `terraform init`.
5. Review the plan: `terraform plan`.
6. Apply the configuration: `terraform apply`.
7. Confirm the changes when prompted.

### Notes:
- The `aws_organizations` module should handle the creation of AWS accounts and organizational units. You can define it in a separate file for modularity.
- Replace placeholder values for emails, account IDs, and bucket names with actual values before applying the configuration.
- Ensure you have the necessary permissions to create AWS Organizations and accounts.