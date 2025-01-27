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
  # Default region for the provider
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

# S3 bucket to store CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${var.project_name}-cloudtrail-logs-${random_string.suffix.result}"

  acl    = "private"
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }

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
  default     = "us-east-1" # Default region
}

variable "enable_multi_region" {
  description = "Enable multi-region support for CloudTrail."
  type        = bool
  default     = true # Based on user input
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

# Instructions:
# 1. Save this script in a file, e.g., `main.tf`.
# 2. Initialize Terraform: `terraform init`.
# 3. Review the plan: `terraform plan`.
# 4. Apply the configuration: `terraform apply`.
# 5. Confirm the changes when prompted.
```

### Key Assumptions:
1. **Multi-region support**: Enabled based on user input.
2. **AWS Organizations**: Not used, as per user input.
3. **Centralized logging**: Not implemented, as per user input.
4. **Default region**: Set to `us-east-1` but can be overridden via variables.
5. **Project name**: Defaulted to "hello" based on user input.

### Notes:
- Ensure you have the necessary IAM permissions to create CloudTrail and S3 resources.
- The S3 bucket name is made unique using a random string to avoid naming conflicts.
- Sensitive data (e.g., access keys) should be managed securely using Terraform variables or a secrets manager.