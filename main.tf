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

# AWS Organizations setup
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

# Organizational Units
resource "aws_organizations_organizational_unit" "ou" {
  for_each = toset(var.organizational_units)

  name      = each.value
  parent_id = aws_organizations_organization.org.id
}

# Accounts
resource "aws_organizations_account" "master_account" {
  email      = var.master_account_email
  name       = "MasterAccount"
  role_name  = "OrganizationAccountAccessRole"
  parent_id  = aws_organizations_organization.org.id
}

resource "aws_organizations_account" "development_account" {
  email      = var.development_account_email
  name       = "DevelopmentAccount"
  role_name  = "OrganizationAccountAccessRole"
  parent_id  = aws_organizations_organizational_unit.ou["Sandbox"].id
}

resource "aws_organizations_account" "production_account" {
  email      = var.production_account_email
  name       = "ProductionAccount"
  role_name  = "OrganizationAccountAccessRole"
  parent_id  = aws_organizations_organizational_unit.ou["Security"].id
}

resource "aws_organizations_account" "shared_account" {
  email      = var.shared_account_email
  name       = "SharedAccount"
  role_name  = "OrganizationAccountAccessRole"
  parent_id  = aws_organizations_organizational_unit.ou["Audit Log"].id
}

resource "aws_organizations_account" "security_account" {
  email      = var.security_account_email
  name       = "SecurityAccount"
  role_name  = "OrganizationAccountAccessRole"
  parent_id  = aws_organizations_organizational_unit.ou["Security"].id
}

resource "aws_organizations_account" "audit_account" {
  email      = var.audit_account_email
  name       = "AuditAccount"
  role_name  = "OrganizationAccountAccessRole"
  parent_id  = aws_organizations_organizational_unit.ou["Audit Log"].id
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
output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = aws_organizations_organization.org.id
}

output "organizational_units" {
  description = "The created organizational units."
  value       = aws_organizations_organizational_unit.ou
}

output "aft_logs_bucket_name" {
  description = "The name of the S3 bucket for AFT logs."
  value       = aws_s3_bucket.aft_logs.bucket
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file to define the variables or pass them via `terraform.tfvars`.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Notes:
- Replace the default values in `terraform.tfvars` or pass them as CLI arguments.
- Ensure the AWS credentials are configured in your environment before running the script.
- The script assumes that AWS Control Tower is not explicitly enabled but uses AWS Organizations for account and OU management.