```hcl
# main.tf
# This Terraform configuration sets up an AWS environment with Control Tower enabled.
# It includes organizational units, accounts, and an S3 bucket for AFT logs.

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

# Variables
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-west-2" # Default region, can be overridden
}

variable "master_account_email" {
  description = "Email address of the AWS master account."
  type        = string
}

variable "master_account_id" {
  description = "Account ID of the AWS master account."
  type        = string
}

variable "dev_account_email" {
  description = "Email address assigned to the Dev account."
  type        = string
}

variable "prod_account_email" {
  description = "Email address assigned to the Prod account."
  type        = string
}

variable "aft_logs_bucket_name" {
  description = "Name of the AFT logs bucket."
  type        = string
}

variable "organizational_units" {
  description = "List of organizational units to create."
  type        = list(string)
  default     = ["Dev", "Prod"] # Default OUs
}

# AWS Control Tower Setup
module "control_tower" {
  source = "./modules/control_tower"

  master_account_email = var.master_account_email
  master_account_id    = var.master_account_id
  dev_account_email    = var.dev_account_email
  prod_account_email   = var.prod_account_email
  organizational_units = var.organizational_units
}

# S3 Bucket for AFT Logs
resource "aws_s3_bucket" "aft_logs" {
  bucket = var.aft_logs_bucket_name

  tags = {
    Name        = "AFT Logs Bucket"
    Environment = "Control Tower"
  }
}

# Outputs
output "aft_logs_bucket_name" {
  description = "The name of the AFT logs bucket."
  value       = aws_s3_bucket.aft_logs.bucket
}

output "organizational_units" {
  description = "List of organizational units created."
  value       = var.organizational_units
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `modules/control_tower` directory and define the Control Tower module there (not included in this script for brevity).
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- The AWS Control Tower module (`modules/control_tower`) is pre-defined and handles the creation of accounts and organizational units.
- Sensitive data like account emails and IDs are passed as variables to avoid hardcoding.
- The default AWS region is set to `us-west-2` but can be overridden using the `aws_region` variable.
- The AFT logs bucket follows the naming convention `aft-logs-bucket-<master_account_id>` and is passed as a variable.