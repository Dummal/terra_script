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
resource "aws_cloudtrail" "landing_zone_trail" {
  name                          = "${var.project_name}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = var.enable_multi_region
  enable_log_file_validation    = true
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.project_name}-cloudtrail-logs-${random_string.suffix.result}"
  acl    = "private"

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

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Random string to ensure unique bucket name
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Variables
variable "project_name" {
  description = "The name of the project or organization."
  type        = string
  default     = "hello" # Default value based on user input
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

variable "environment" {
  description = "The environment for the resources (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

# Outputs
output "cloudtrail_name" {
  description = "The name of the CloudTrail."
  value       = aws_cloudtrail.landing_zone_trail.name
}

output "cloudtrail_s3_bucket" {
  description = "The S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
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
- The project name is "hello" as per user input.
- Multi-region support is enabled for CloudTrail.
- AWS Organizations is not used, so no account management is included.
- Logs are not centralized into a logging account.
- Default AWS region is set to `us-east-1`.
- Sensitive data like access keys are managed outside this script (e.g., via environment variables or AWS CLI configuration).