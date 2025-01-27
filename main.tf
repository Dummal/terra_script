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
resource "aws_cloudtrail" "landing_zone_trail" {
  name                          = "${var.organization_name}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  tags = var.default_tags
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.organization_name}-cloudtrail-logs"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.default_tags
}

# IAM role for CloudTrail
resource "aws_iam_role" "cloudtrail_role" {
  name               = "${var.organization_name}-cloudtrail-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role_policy.json

  tags = var.default_tags
}

data "aws_iam_policy_document" "cloudtrail_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

# Attach policy to the IAM role
resource "aws_iam_role_policy_attachment" "cloudtrail_policy_attachment" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCloudTrailFullAccess"
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

variable "default_tags" {
  description = "Default tags to apply to all resources."
  type        = map(string)
  default = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# Outputs
output "cloudtrail_name" {
  description = "The name of the CloudTrail instance."
  value       = aws_cloudtrail.landing_zone_trail.name
}

output "cloudtrail_s3_bucket" {
  description = "The S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_role_arn" {
  description = "The ARN of the IAM role used by CloudTrail."
  value       = aws_iam_role.cloudtrail_role.arn
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
- AWS Organizations is not used, so no additional account management is included.
- Logs are stored in a dedicated S3 bucket with versioning and encryption enabled.
- Default tags are applied to all resources for better resource management.
- Sensitive data like organization name and region are parameterized using variables.