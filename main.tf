```hcl
# main.tf
# This Terraform script sets up a basic AWS Landing Zone with multi-region support and CloudTrail logging enabled.

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
  name                          = "landingzone-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = var.enable_multi_region
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

  tags = var.default_tags
}

# IAM role for CloudTrail
resource "aws_iam_role" "cloudtrail_role" {
  name = "cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
      }
    ]
  })

  tags = var.default_tags
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
  default     = "default-org" # Replace with your organization name
}

variable "default_region" {
  description = "The default AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "enable_multi_region" {
  description = "Enable multi-region support for CloudTrail."
  type        = bool
  default     = true
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
  value       = aws_cloudtrail.main.name
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
2. Create a `variables.tf` file if you want to override default values.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- Multi-region support is enabled by default (`enable_multi_region = true`).
- AWS Organizations is not used, so accounts are managed manually.
- Logs are not centralized into a separate logging account.
- Replace `default-org` with your organization name in the `organization_name` variable.