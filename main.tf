```hcl
# main.tf
# This Terraform script sets up a multi-region AWS environment with CloudTrail enabled.
# Assumptions:
# - AWS Organizations is not used.
# - Logs are not centralized across accounts.
# - User-provided inputs are used for username and email.

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
  region = var.default_region
}

# Enable AWS CloudTrail for logging
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = var.enable_multi_region
  enable_logging                = true

  tags = {
    Project = var.project_name
    Owner   = var.username
  }
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.project_name}-cloudtrail-logs"

  tags = {
    Project = var.project_name
    Owner   = var.username
  }
}

# S3 bucket policy to allow CloudTrail to write logs
resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Variables
variable "project_name" {
  description = "The name of the project or organization."
  type        = string
  default     = "default-project" # Replace with a meaningful default if needed
}

variable "enable_multi_region" {
  description = "Enable multi-region support for CloudTrail."
  type        = bool
  default     = true
}

variable "username" {
  description = "The username for the landing zone."
  type        = string
  default     = "default-user" # Replace with a meaningful default if needed
}

variable "email" {
  description = "The email address for the landing zone."
  type        = string
  default     = "default@example.com" # Replace with a meaningful default if needed
}

variable "default_region" {
  description = "The default AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

# Outputs
output "cloudtrail_name" {
  description = "The name of the CloudTrail instance."
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_s3_bucket" {
  description = "The S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_multi_region" {
  description = "Indicates if multi-region support is enabled for CloudTrail."
  value       = aws_cloudtrail.main.is_multi_region_trail
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file if you want to override the default values for variables.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Notes:
- Replace default values in the `variables` block with actual values as needed.
- Ensure the AWS credentials are configured in your environment before running the script.
- This script assumes that AWS Organizations is not used and logs are not centralized across accounts. Adjust as needed for your use case.