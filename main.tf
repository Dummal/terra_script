```hcl
# main.tf
# Terraform script to set up a basic AWS Landing Zone with multi-region support and AWS CloudTrail logging enabled.

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
  region = var.primary_region
}

# Enable AWS CloudTrail for logging
resource "aws_cloudtrail" "main" {
  name                          = "${var.organization_name}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  tags = {
    Environment = var.environment
    Project     = var.organization_name
  }
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.organization_name}-cloudtrail-logs"
  acl    = "private"

  tags = {
    Environment = var.environment
    Project     = var.organization_name
  }
}

# S3 bucket policy to allow CloudTrail to write logs
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
        Action    = "s3:GetBucketAcl"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.id}"
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.id}/*"
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
variable "organization_name" {
  description = "The name of your organization or project."
  type        = string
  default     = "default-organization" # Replace with your organization name
}

variable "primary_region" {
  description = "The primary AWS region for the landing zone."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment for the resources (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
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
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file if you want to override the default values for variables.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- Multi-region support is enabled via `is_multi_region_trail = true` in the CloudTrail configuration.
- AWS Organizations is not used, so no account management is included.
- Logs are not centralized into a separate logging account but stored in an S3 bucket in the same account.
- Replace default values for `organization_name`, `primary_region`, and `environment` as needed.