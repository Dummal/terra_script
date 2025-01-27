```hcl
# main.tf
# Terraform configuration for setting up a multi-region AWS environment with CloudTrail logging enabled.

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.default_region
}

# Enable AWS CloudTrail for logging
module "cloudtrail" {
  source = "./modules/cloudtrail"

  enable_logging = true
  trail_name     = var.cloudtrail_name
  s3_bucket_name = var.cloudtrail_s3_bucket_name
  tags           = var.common_tags
}

# Variables
variable "default_region" {
  description = "Default AWS region for the provider"
  type        = string
  default     = "us-east-1"
}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
  default     = "default-cloudtrail"
}

variable "cloudtrail_s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
  default     = "cloudtrail-logs-bucket"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Hello"
    Environment = "Production"
    Owner       = "Hello"
  }
}

# Outputs
output "cloudtrail_trail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = module.cloudtrail.trail_arn
}

output "cloudtrail_s3_bucket_name" {
  description = "The name of the S3 bucket used for CloudTrail logs"
  value       = module.cloudtrail.s3_bucket_name
}
```

```hcl
# modules/cloudtrail/main.tf
# Module to configure AWS CloudTrail

resource "aws_cloudtrail" "this" {
  name                          = var.trail_name
  s3_bucket_name                = var.s3_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = var.enable_logging

  tags = var.tags
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = var.s3_bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action    = "s3:GetBucketAcl"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.id}"
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Outputs
output "trail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = aws_cloudtrail.this.arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket used for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.id
}
```

```hcl
# modules/cloudtrail/variables.tf
# Variables for the CloudTrail module

variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "enable_logging" {
  description = "Enable or disable CloudTrail logging"
  type        = bool
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
```

### Instructions to Apply:
1. Save the main configuration in `main.tf`.
2. Save the module files in `modules/cloudtrail/` directory.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- Multi-region support is enabled via `is_multi_region_trail = true` in the CloudTrail configuration.
- AWS Organizations is not used, so no additional account management is included.
- Logs are not centralized into a separate logging account.
- Default values are provided for the project name, owner, and environment tags. Update these as needed.