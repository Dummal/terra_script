```hcl
# main.tf
# Terraform script to create a multi-region AWS landing zone with CloudTrail enabled.
# Assumptions:
# - AWS Organizations is not used.
# - Logs are not centralized across accounts.
# - Multi-region support is enabled.
# - Sensitive data like email and username are passed as variables.

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
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "${var.project_name}-cloudtrail-logs"

  acl = "private"

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

# IAM role for CloudTrail
resource "aws_iam_role" "cloudtrail_role" {
  name = "${var.project_name}-cloudtrail-role"

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

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach policy to the IAM role
resource "aws_iam_role_policy_attachment" "cloudtrail_policy_attachment" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCloudTrailFullAccess"
}

# Variables
variable "project_name" {
  description = "Name of the project or organization"
  type        = string
  default     = "default_project" # Replace with a meaningful default
}

variable "default_region" {
  description = "Default AWS region for the landing zone"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment for the resources (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

# Outputs
output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = aws_cloudtrail.landing_zone_trail.name
}

output "cloudtrail_bucket" {
  description = "S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_bucket.bucket
}

output "cloudtrail_role" {
  description = "IAM role for CloudTrail"
  value       = aws_iam_role.cloudtrail_role.name
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file if you want to override the default values for variables.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Notes:
- Replace `default_project` in the `project_name` variable with your project name.
- Ensure the AWS credentials are configured in your environment before running the script.
- This script assumes that AWS Organizations is not used and logs are not centralized. If these assumptions change, the script will need to be updated.