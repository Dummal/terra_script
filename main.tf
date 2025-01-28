```hcl
# main.tf
# Terraform script to set up a basic AWS Landing Zone with AWS Organizations and CloudTrail logging.

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

# AWS Organizations setup
resource "aws_organizations_organization" "main" {
  feature_set = "ALL"

  # Tags for resource identification
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# AWS CloudTrail setup
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_logging                = true

  # Tags for resource identification
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.project_name}-cloudtrail-logs"

  # Enable versioning for log integrity
  versioning {
    enabled = true
  }

  # Enable server-side encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Tags for resource identification
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# IAM policy for CloudTrail to write to the S3 bucket
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
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
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
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project or organization"
  type        = string
  default     = "hello" # Default value based on user input
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.main.id
}

output "cloudtrail_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_name" {
  description = "The name of the CloudTrail"
  value       = aws_cloudtrail.main.name
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file if you want to override default values for variables.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- Multi-region support is disabled as per user input.
- Centralized logging is not enabled as per user input.
- Default values for `project_name` and `environment` are set to "hello" and "dev" respectively, based on user input.
- The script assumes the AWS account has sufficient permissions to create AWS Organizations, CloudTrail, and S3 resources.