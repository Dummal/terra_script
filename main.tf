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
  enable_logging                = true

  tags = var.default_tags
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

  tags = var.default_tags
}

# IAM role for CloudTrail
resource "aws_iam_role" "cloudtrail_role" {
  name               = var.cloudtrail_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role_policy.json

  tags = var.default_tags
}

# IAM policy for CloudTrail
resource "aws_iam_policy" "cloudtrail_policy" {
  name        = var.cloudtrail_iam_policy_name
  description = "Policy for CloudTrail to access S3 bucket and logs"
  policy      = data.aws_iam_policy_document.cloudtrail_policy.json
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "cloudtrail_policy_attachment" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = aws_iam_policy.cloudtrail_policy.arn
}

# Data source for IAM assume role policy
data "aws_iam_policy_document" "cloudtrail_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

# Data source for IAM policy document
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
}

# Variables
variable "default_region" {
  description = "Default AWS region"
  type        = string
  default     = "us-east-1"
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

variable "cloudtrail_iam_role_name" {
  description = "Name of the IAM role for CloudTrail"
  type        = string
  default     = "landingzone-cloudtrail-role"
}

variable "cloudtrail_iam_policy_name" {
  description = "Name of the IAM policy for CloudTrail"
  type        = string
  default     = "landingzone-cloudtrail-policy"
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
    Project     = "landingzone"
  }
}

# Outputs
output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_s3_bucket" {
  description = "S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_iam_role" {
  description = "IAM role for CloudTrail"
  value       = aws_iam_role.cloudtrail_role.name
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
- AWS Organizations is not used.
- Logs are not centralized into a separate logging account.
- Default region is `us-east-1`.
- Sensitive data like bucket names and IAM role names are parameterized for flexibility.