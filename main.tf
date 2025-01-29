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

# AWS Organizations setup
module "aws_organizations" {
  source = "./modules/aws_organizations"

  organization_name = var.organization_name
  admin_email       = var.admin_email
  landing_zone_user = var.landing_zone_user
}

# AWS CloudTrail setup
module "cloudtrail" {
  source = "./modules/cloudtrail"

  enable_cloudtrail = var.enable_cloudtrail
  trail_name        = var.trail_name
  s3_bucket_name    = var.cloudtrail_s3_bucket_name
  log_group_name    = var.cloudtrail_log_group_name
}

# Centralized logging setup
module "centralized_logging" {
  source = "./modules/centralized_logging"

  enable_centralized_logging = var.enable_centralized_logging
  logging_account_id         = var.logging_account_id
  log_bucket_name            = var.log_bucket_name
}

# Variables
variable "organization_name" {
  description = "The name of your organization or project."
  type        = string
}

variable "default_region" {
  description = "The default AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "admin_email" {
  description = "The email address for the landing zone administrator."
  type        = string
}

variable "landing_zone_user" {
  description = "The username for the landing zone administrator."
  type        = string
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail logging services."
  type        = bool
  default     = true
}

variable "trail_name" {
  description = "The name of the CloudTrail trail."
  type        = string
  default     = "organization-trail"
}

variable "cloudtrail_s3_bucket_name" {
  description = "The S3 bucket name for CloudTrail logs."
  type        = string
  default     = "cloudtrail-logs-bucket"
}

variable "cloudtrail_log_group_name" {
  description = "The CloudWatch log group name for CloudTrail logs."
  type        = string
  default     = "cloudtrail-log-group"
}

variable "enable_centralized_logging" {
  description = "Enable centralized logging for all accounts."
  type        = bool
  default     = true
}

variable "logging_account_id" {
  description = "The AWS account ID for the logging account."
  type        = string
}

variable "log_bucket_name" {
  description = "The S3 bucket name for centralized logs."
  type        = string
  default     = "centralized-logs-bucket"
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = module.aws_organizations.organization_id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = module.cloudtrail.trail_arn
}

output "centralized_log_bucket_arn" {
  description = "The ARN of the centralized logging S3 bucket."
  value       = module.centralized_logging.bucket_arn
}
```

### Modules Directory Structure
1. **`modules/aws_organizations`**: Contains the configuration for AWS Organizations.
2. **`modules/cloudtrail`**: Contains the configuration for AWS CloudTrail.
3. **`modules/centralized_logging`**: Contains the configuration for centralized logging.

### Instructions to Apply
1. Save the script in a file, e.g., `main.tf`.
2. Create the `modules` directory and populate it with the respective module configurations.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions
- Multi-region support is enabled by default through AWS Organizations.
- AWS CloudTrail and centralized logging are enabled as per the requirements.
- Sensitive data like emails and usernames are passed as variables for security.
- Default values are provided for regions and resource names where not explicitly specified.