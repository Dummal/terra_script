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

# Variables
variable "organization_name" {
  description = "The name of the organization or project."
  type        = string
}

variable "landing_zone_username" {
  description = "The username for the landing zone."
  type        = string
}

variable "landing_zone_email" {
  description = "The email address for the landing zone."
  type        = string
}

variable "default_region" {
  description = "The default AWS region for the landing zone."
  type        = string
  default     = "us-east-1"
}

variable "enable_multi_region" {
  description = "Enable multi-region support for the landing zone."
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail logging services."
  type        = bool
  default     = true
}

variable "centralize_logs" {
  description = "Centralize logs from all accounts into the logging account."
  type        = bool
  default     = true
}

# AWS Organizations
resource "aws_organizations_organization" "main" {
  feature_set = "ALL"
}

# CloudTrail
resource "aws_cloudtrail" "main" {
  count                  = var.enable_cloudtrail ? 1 : 0
  name                   = "${var.organization_name}-cloudtrail"
  s3_bucket_name         = aws_s3_bucket.cloudtrail_logs.bucket
  is_multi_region_trail  = var.enable_multi_region
  include_global_service_events = true
  enable_logging         = true
}

# S3 Bucket for CloudTrail Logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.organization_name}-cloudtrail-logs"

  tags = {
    Name        = "${var.organization_name}-cloudtrail-logs"
    Environment = "Production"
  }
}

# Centralized Logging (Optional)
resource "aws_s3_bucket" "centralized_logs" {
  count  = var.centralize_logs ? 1 : 0
  bucket = "${var.organization_name}-centralized-logs"

  tags = {
    Name        = "${var.organization_name}-centralized-logs"
    Environment = "Production"
  }
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = aws_organizations_organization.main.id
}

output "cloudtrail_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "centralized_logs_bucket_name" {
  description = "The name of the S3 bucket for centralized logs."
  value       = aws_s3_bucket.centralized_logs[0].bucket
  condition   = var.centralize_logs
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file to define the variables if needed.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- The organization name, username, and email are provided as inputs.
- Multi-region support, CloudTrail, and centralized logging are enabled by default.
- S3 buckets are created for CloudTrail and centralized logging.
- Tags are added for better resource management.