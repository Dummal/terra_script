```hcl
# main.tf
# Terraform script to set up an AWS Landing Zone with AWS Organizations and CloudTrail logging.

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

# AWS Organizations - Create an organization
resource "aws_organizations_organization" "main" {
  feature_set = "ALL"

  # Tags for resource identification
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# AWS CloudTrail - Enable logging
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

# S3 Bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.project_name}-cloudtrail-logs"

  # Enable versioning for the bucket
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

# IAM Role for CloudTrail
resource "aws_iam_role" "cloudtrail_role" {
  name               = "${var.project_name}-cloudtrail-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role_policy.json

  # Tags for resource identification
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# IAM Policy for CloudTrail
resource "aws_iam_policy" "cloudtrail_policy" {
  name        = "${var.project_name}-cloudtrail-policy"
  description = "Policy for CloudTrail to access S3 bucket and CloudWatch logs"
  policy      = data.aws_iam_policy_document.cloudtrail_policy.json
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "cloudtrail_policy_attachment" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = aws_iam_policy.cloudtrail_policy.arn
}

# Data sources for IAM policy documents
data "aws_iam_policy_document" "cloudtrail_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_policy" {
  statement {
    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.cloudtrail_logs.arn,
      "${aws_s3_bucket.cloudtrail_logs.arn}/*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
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
  default     = "example-project"
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

output "cloudtrail_role_arn" {
  description = "The ARN of the IAM role for CloudTrail"
  value       = aws_iam_role.cloudtrail_role.arn
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
- Multi-region support is not required (`is_multi_region_trail = false`).
- Centralized logging is not enabled.
- The project name and environment are provided as variables for flexibility.
- Default AWS region is `us-east-1`, but it can be overridden using the `aws_region` variable.