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

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Random string to ensure unique bucket name
resource "random_string" "suffix" {
  length  = 6
  special = false
}

# Variables
variable "project_name" {
  description = "The name of the project or organization."
  type        = string
  default     = "default-project" # Replace with your project name
}

variable "default_region" {
  description = "The default AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "enable_multi_region" {
  description = "Enable multi-region support for AWS CloudTrail."
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
  description = "The name of the AWS CloudTrail."
  value       = aws_cloudtrail.landing_zone_trail.name
}

output "cloudtrail_s3_bucket" {
  description = "The S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

# Instructions:
# 1. Save this script in a file, e.g., `main.tf`.
# 2. Create a `variables.tf` file if you want to override default values.
# 3. Run `terraform init` to initialize the Terraform working directory.
# 4. Run `terraform plan` to review the changes.
# 5. Run `terraform apply` to apply the configuration.
```

### Assumptions:
1. **Multi-region support**: Enabled by default (`enable_multi_region = true`).
2. **AWS Organizations**: Not used, as per the user input.
3. **Centralized logging**: Not implemented, as per the user input.
4. **Sensitive data**: No sensitive data is hardcoded; variables are used for customization.
5. **Project name**: Defaulted to `default-project` but can be overridden via variables.

### Notes:
- The script creates an S3 bucket for CloudTrail logs with a unique name using a random string suffix.
- Tags are added to resources for better management and identification.
- The script is modular and can be extended further by creating separate modules for additional resources.