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
  region = var.default_region
}

# Enable AWS CloudTrail for logging
resource "aws_cloudtrail" "main" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = var.enable_multi_region
  enable_log_file_validation    = true
  tags                          = var.default_tags
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = var.cloudtrail_s3_bucket_name

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

  # Block public access
  block_public_access {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  tags = var.default_tags
}

# IAM Role for CloudTrail to assume
resource "aws_iam_role" "cloudtrail_role" {
  name               = var.cloudtrail_role_name
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role_policy.json

  tags = var.default_tags
}

# IAM Policy for CloudTrail
resource "aws_iam_policy" "cloudtrail_policy" {
  name        = var.cloudtrail_policy_name
  description = "Policy for CloudTrail to write logs to S3"
  policy      = data.aws_iam_policy_document.cloudtrail_policy.json
}

# Attach the policy to the role
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
    actions   = ["s3:PutObject", "s3:GetBucketAcl", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.cloudtrail_logs.arn, "${aws_s3_bucket.cloudtrail_logs.arn}/*"]
  }
}

# Variables
variable "default_region" {
  description = "Default AWS region"
  type        = string
  default     = "us-east-1"
}

variable "enable_multi_region" {
  description = "Enable multi-region support for CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail"
  type        = string
  default     = "landingzone-cloudtrail"
}

variable "cloudtrail_s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  type        = string
  default     = "landingzone-cloudtrail-logs"
}

variable "cloudtrail_role_name" {
  description = "Name of the IAM role for CloudTrail"
  type        = string
  default     = "landingzone-cloudtrail-role"
}

variable "cloudtrail_policy_name" {
  description = "Name of the IAM policy for CloudTrail"
  type        = string
  default     = "landingzone-cloudtrail-policy"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "landingzone"
  }
}

# Outputs
output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_role_arn" {
  description = "ARN of the IAM role for CloudTrail"
  value       = aws_iam_role.cloudtrail_role.arn
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file if you want to override default values.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- Multi-region support is enabled by default (`enable_multi_region = true`).
- AWS Organizations is not used, so accounts are managed manually.
- Logs are not centralized into a separate logging account.
- Default tags are applied to all resources for better organization and cost tracking.