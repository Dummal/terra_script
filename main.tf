```hcl
# Terraform script to create a multi-region AWS landing zone with CloudTrail enabled
# Assumptions:
# - AWS Organizations is not used for account management.
# - Logs are not centralized into a logging account.
# - Multi-region support is enabled.
# - Sensitive data like email and username are passed as variables.

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

# Provider configuration
provider "aws" {
  region = var.default_region
}

# Variables
variable "default_region" {
  description = "The default AWS region for the landing zone."
  type        = string
  default     = "us-east-1"
}

variable "additional_regions" {
  description = "List of additional AWS regions for multi-region support."
  type        = list(string)
  default     = ["us-west-1", "us-west-2"]
}

variable "landing_zone_username" {
  description = "Username for the landing zone."
  type        = string
}

variable "landing_zone_email" {
  description = "Email address for the landing zone."
  type        = string
}

# Enable CloudTrail for logging
resource "aws_cloudtrail" "main" {
  name                          = "landing-zone-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail_logs.arn
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn
  tags = {
    Environment = "LandingZone"
    Owner       = var.landing_zone_username
  }
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "landing-zone-cloudtrail-logs-${random_id.suffix.hex}"
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
    Environment = "LandingZone"
    Owner       = var.landing_zone_username
  }
}

# Random ID for unique bucket name
resource "random_id" "suffix" {
  byte_length = 4
}

# CloudWatch log group for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name              = "/aws/cloudtrail/landing-zone"
  retention_in_days = 90

  tags = {
    Environment = "LandingZone"
    Owner       = var.landing_zone_username
  }
}

# IAM role for CloudTrail to write to CloudWatch
resource "aws_iam_role" "cloudtrail_role" {
  name = "landing-zone-cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = "LandingZone"
    Owner       = var.landing_zone_username
  }
}

# IAM policy for CloudTrail role
resource "aws_iam_policy" "cloudtrail_policy" {
  name        = "landing-zone-cloudtrail-policy"
  description = "Policy for CloudTrail to write logs to CloudWatch and S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
      },
      {
        Action = [
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "cloudtrail_policy_attachment" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = aws_iam_policy.cloudtrail_policy.arn
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

output "cloudtrail_log_group" {
  description = "The CloudWatch log group used for CloudTrail logs."
  value       = aws_cloudwatch_log_group.cloudtrail_logs.name
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file to define and override variables if needed.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Notes:
- Replace `landing_zone_username` and `landing_zone_email` with appropriate values in a `terraform.tfvars` file or pass them as CLI arguments.
- Ensure the AWS credentials are configured in your environment before running the script.
- The script assumes multi-region support and enables CloudTrail across all specified regions.