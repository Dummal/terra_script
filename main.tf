```hcl
# Terraform script to create a multi-region AWS landing zone with CloudTrail enabled
# Assumptions:
# - AWS Organizations is not used.
# - Logs are not centralized across accounts.
# - Multi-region support is enabled.
# - CloudTrail logging is enabled.
# - Sensitive data like email and username are passed as variables.

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
  # Default region for the provider
  region = var.default_region
}

# Variables
variable "default_region" {
  description = "The default AWS region for the landing zone."
  type        = string
  default     = "us-east-1"
}

variable "additional_regions" {
  description = "List of additional AWS regions for multi-region support."
  type        = list(string)
  default     = ["us-west-1", "us-west-2"]
}

variable "landing_zone_username" {
  description = "Username for the landing zone."
  type        = string
}

variable "landing_zone_email" {
  description = "Email address for the landing zone."
  type        = string
}

variable "enable_cloudtrail" {
  description = "Flag to enable AWS CloudTrail logging."
  type        = bool
  default     = true
}

# Resource: AWS CloudTrail
resource "aws_cloudtrail" "landing_zone_trail" {
  count                  = var.enable_cloudtrail ? 1 : 0
  name                   = "landing-zone-cloudtrail"
  s3_bucket_name         = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail  = true
  enable_logging         = true

  tags = {
    Environment = "LandingZone"
    Owner       = var.landing_zone_username
  }
}

# Resource: S3 Bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "landing-zone-cloudtrail-logs-${random_id.bucket_id.hex}"

  tags = {
    Environment = "LandingZone"
    Owner       = var.landing_zone_username
  }
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

# Outputs
output "cloudtrail_name" {
  description = "The name of the CloudTrail created for the landing zone."
  value       = aws_cloudtrail.landing_zone_trail[0].name
  condition   = var.enable_cloudtrail
}

output "cloudtrail_s3_bucket" {
  description = "The S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_bucket.id
}

# Instructions:
# 1. Save this script in a file, e.g., `main.tf`.
# 2. Create a `variables.tf` file to define and override variables if needed.
# 3. Run `terraform init` to initialize the Terraform working directory.
# 4. Run `terraform plan` to review the changes.
# 5. Run `terraform apply` to apply the configuration.
```