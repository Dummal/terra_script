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
  tags                              = var.default_tags
}

# Module: CloudTrail
module "cloudtrail" {
  source = "./modules/cloudtrail"

  enable_cloudtrail = var.enable_cloudtrail
  trail_name        = var.cloudtrail_name
  s3_bucket_name    = var.cloudtrail_s3_bucket_name
  tags              = var.default_tags
}

# Module: Centralized Logging
module "centralized_logging" {
  source = "./modules/centralized_logging"

  logging_account_email = var.logging_account_email
  logging_account_name  = var.logging_account_name
  logs_s3_bucket_name   = var.logs_s3_bucket_name
  tags                  = var.default_tags
}

# Variables
variable "default_region" {
  description = "Default AWS region for the infrastructure"
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

variable "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
  default     = "organization-cloudtrail"
}

variable "cloudtrail_s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "logging_account_email" {
  description = "Email address for the centralized logging account"
  type        = string
}

variable "logging_account_name" {
  description = "Name for the centralized logging account"
  type        = string
}

variable "logs_s3_bucket_name" {
  description = "S3 bucket name for centralized logs"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "LandingZone"
  }
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = module.aws_organizations.organization_id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = module.cloudtrail.trail_arn
}

output "logging_account_id" {
  description = "The ID of the centralized logging account"
  value       = module.centralized_logging.logging_account_id
}
```

### Modules Directory Structure
1. **`modules/aws_organizations`**:
   - Handles AWS Organizations setup.
   - Creates the master account and organizational units.

2. **`modules/cloudtrail`**:
   - Configures AWS CloudTrail for logging.
   - Creates an S3 bucket for storing logs.

3. **`modules/centralized_logging`**:
   - Sets up a centralized logging account.
   - Creates an S3 bucket for storing logs from all accounts.

### Instructions to Apply
1. Save the script in a file, e.g., `main.tf`.
2. Create the `modules` directory and populate it with the respective module configurations.
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Review the plan:
   ```bash
   terraform plan -var="organization_master_account_email=example@example.com" -var="organization_master_account_name=MasterAccount" -var="cloudtrail_s3_bucket_name=my-cloudtrail-bucket" -var="logging_account_email=logging@example.com" -var="logging_account_name=LoggingAccount" -var="logs_s3_bucket_name=my-logs-bucket"
   ```
5. Apply the configuration:
   ```bash
   terraform apply -var="organization_master_account_email=example@example.com" -var="organization_master_account_name=MasterAccount" -var="cloudtrail_s3_bucket_name=my-cloudtrail-bucket" -var="logging_account_email=logging@example.com" -var="logging_account_name=LoggingAccount" -var="logs_s3_bucket_name=my-logs-bucket"
   ```
6. Confirm the changes when prompted.