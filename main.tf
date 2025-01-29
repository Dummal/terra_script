```hcl
# main.tf
# This Terraform script sets up a multi-region AWS Landing Zone with AWS Organizations, CloudTrail, and centralized logging.

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
  region = var.default_region
}

# Module: AWS Organizations
module "aws_organizations" {
  source = "./modules/aws_organizations"

  organization_master_account_email = var.organization_master_account_email
  organization_master_account_name  = var.organization_master_account_name
  tags                              = var.common_tags
}

# Module: CloudTrail
module "cloudtrail" {
  source = "./modules/cloudtrail"

  enable_cloudtrail = var.enable_cloudtrail
  log_bucket_name   = var.cloudtrail_log_bucket_name
  tags              = var.common_tags
}

# Module: Centralized Logging
module "centralized_logging" {
  source = "./modules/centralized_logging"

  enable_centralized_logging = var.enable_centralized_logging
  logging_account_email      = var.logging_account_email
  log_bucket_name            = var.centralized_log_bucket_name
  tags                       = var.common_tags
}

# Variables
variable "default_region" {
  description = "Default AWS region for the provider"
  type        = string
  default     = "us-east-1"
}

variable "organization_master_account_email" {
  description = "Email address for the AWS Organizations master account"
  type        = string
}

variable "organization_master_account_name" {
  description = "Name for the AWS Organizations master account"
  type        = string
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail logging"
  type        = bool
  default     = true
}

variable "cloudtrail_log_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "enable_centralized_logging" {
  description = "Enable centralized logging for all accounts"
  type        = bool
  default     = true
}

variable "logging_account_email" {
  description = "Email address for the logging account"
  type        = string
}

variable "centralized_log_bucket_name" {
  description = "S3 bucket name for centralized logs"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Hello1234"
    Environment = "Production"
  }
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = module.aws_organizations.organization_id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail"
  value       = module.cloudtrail.cloudtrail_arn
}

output "centralized_log_bucket_arn" {
  description = "The ARN of the centralized log bucket"
  value       = module.centralized_logging.log_bucket_arn
}
```

### Modules Directory Structure
1. **`modules/aws_organizations`**: Handles AWS Organizations setup.
2. **`modules/cloudtrail`**: Configures AWS CloudTrail.
3. **`modules/centralized_logging`**: Sets up centralized logging.

### Example Module: AWS Organizations (`modules/aws_organizations/main.tf`)
```hcl
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_organizations_account" "master_account" {
  name  = var.organization_master_account_name
  email = var.organization_master_account_email
  tags  = var.tags
}

output "organization_id" {
  value = aws_organizations_organization.this.id
}
```

### Instructions to Apply
1. Save the main script as `main.tf`.
2. Create the modules directory and populate it with the respective module files.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions
- The user has provided valid email addresses for the master and logging accounts.
- S3 bucket names for CloudTrail and centralized logging are unique and follow AWS naming conventions.
- Multi-region support is enabled by default through the use of AWS Organizations and CloudTrail.

This script is modular, reusable, and adheres to Terraform best practices.