```hcl
# main.tf
# Terraform configuration for setting up a multi-region AWS environment with CloudTrail logging enabled.

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
resource "aws_cloudtrail" "main" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = var.enable_multi_region
  enable_logging                = true

  tags = var.default_tags
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = var.cloudtrail_s3_bucket_name

  tags = var.default_tags
}

# S3 bucket policy for CloudTrail logs
resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.bucket}"
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Data source to fetch the current AWS account ID
data "aws_caller_identity" "current" {}

# Variables
variable "default_region" {
  description = "Default AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail"
  type        = string
  default     = "default-cloudtrail"
}

variable "cloudtrail_s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
  default     = "cloudtrail-logs-bucket"
}

variable "enable_multi_region" {
  description = "Enable multi-region support for CloudTrail"
  type        = bool
  default     = true
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "Hello"
  }
}

# Outputs
output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_s3_bucket_name" {
  description = "Name of the S3 bucket used for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file if you want to override any default values.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- Multi-region support is enabled (`enable_multi_region = true`).
- AWS Organizations is not used, so no centralized logging account is configured.
- Default tags are applied to all resources for better resource management.
- The S3 bucket name for CloudTrail logs is unique and globally available. Adjust the `cloudtrail_s3_bucket_name` variable if needed.