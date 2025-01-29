```hcl
# main.tf
# This Terraform script sets up an AWS Control Tower environment with organizational units and accounts.
# Assumptions: The user will provide the required inputs via variables.

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

# AWS Control Tower setup (example resource)
module "control_tower" {
  source = "./modules/control_tower"

  aws_region               = var.aws_region
  master_account_email     = var.master_account_email
  master_account_id        = var.master_account_id
  development_account_email = var.development_account_email
  production_account_email = var.production_account_email
  shared_account_email     = var.shared_account_email
  security_account_email   = var.security_account_email
  audit_account_email      = var.audit_account_email
  aft_logs_bucket_name     = var.aft_logs_bucket_name
  organizational_units     = var.organizational_units
}

# Outputs
output "control_tower_status" {
  description = "Status of the AWS Control Tower setup."
  value       = module.control_tower.status
}

# modules/control_tower/main.tf
# This module sets up AWS Control Tower with the provided accounts and organizational units.

resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

resource "aws_organizations_account" "master_account" {
  name      = "MasterAccount"
  email     = var.master_account_email
  role_name = "OrganizationAccountAccessRole"
}

resource "aws_organizations_account" "development_account" {
  name      = "DevelopmentAccount"
  email     = var.development_account_email
  role_name = "OrganizationAccountAccessRole"
}

resource "aws_organizations_account" "production_account" {
  name      = "ProductionAccount"
  email     = var.production_account_email
  role_name = "OrganizationAccountAccessRole"
}

resource "aws_organizations_account" "shared_account" {
  name      = "SharedAccount"
  email     = var.shared_account_email
  role_name = "OrganizationAccountAccessRole"
}

resource "aws_organizations_account" "security_account" {
  name      = "SecurityAccount"
  email     = var.security_account_email
  role_name = "OrganizationAccountAccessRole"
}

resource "aws_organizations_account" "audit_account" {
  name      = "AuditAccount"
  email     = var.audit_account_email
  role_name = "OrganizationAccountAccessRole"
}

resource "aws_s3_bucket" "aft_logs" {
  bucket = var.aft_logs_bucket_name

  tags = {
    Name        = "AFT Logs Bucket"
    Environment = "Control Tower"
  }
}

resource "aws_organizations_organizational_unit" "organizational_units" {
  for_each = toset(var.organizational_units)

  name = each.value
  parent_id = aws_organizations_organization.org.id
}

output "status" {
  description = "Control Tower setup completed successfully."
  value       = "Control Tower setup is complete with accounts and OUs."
}
```

### Instructions to Apply:
1. Save the main script in a file named `main.tf`.
2. Create a folder named `modules/control_tower` and save the module script in `modules/control_tower/main.tf`.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- The AWS Control Tower setup is being managed via AWS Organizations.
- The user will provide valid email addresses and account IDs.
- Default organizational units are `Security`, `Audit Log`, and `Sandbox` unless specified otherwise.