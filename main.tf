```hcl
# main.tf
# This Terraform script sets up a basic AWS Landing Zone with multi-region support and CloudTrail logging enabled.

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

# Enable AWS CloudTrail for logging
resource "aws_cloudtrail" "landing_zone_trail" {
  name                          = "${var.organization_name}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = var.enable_multi_region
  enable_log_file_validation    = true
  tags = {
    Environment = var.environment
    Owner       = var.username
  }
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.organization_name}-cloudtrail-logs"
  acl    = "private"

  tags = {
    Environment = var.environment
    Owner       = var.username
  }
}

# Variables
variable "organization_name" {
  description = "The name of your organization or project."
  type        = string
  default     = "default-organization"
}

variable "enable_multi_region" {
  description = "Enable multi-region support for CloudTrail."
  type        = bool
  default     = true
}

variable "default_region" {
  description = "The default AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "username" {
  description = "The username for the landing zone."
  type        = string
  default     = "admin"
}

variable "email" {
  description = "The email address for the landing zone."
  type        = string
  default     = "admin@example.com"
}

variable "environment" {
  description = "The environment for the resources (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

# Outputs
output "cloudtrail_name" {
  description = "The name of the CloudTrail."
  value       = aws_cloudtrail.landing_zone_trail.name
}

output "cloudtrail_s3_bucket" {
  description = "The S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file if you want to override the default values for variables.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- Multi-region support is enabled by default (`enable_multi_region = true`).
- AWS Organizations is not used, as per the user input.
- Centralized logging is not required, so logs are stored in a single S3 bucket.
- Default region is set to `us-east-1`, but this can be overridden using the `default_region` variable.
- Sensitive data like usernames and emails are passed as variables to avoid hardcoding.