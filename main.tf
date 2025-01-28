```hcl
# main.tf
# Terraform configuration for a multi-region AWS landing zone with CloudTrail enabled.

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
module "cloudtrail" {
  source = "./modules/cloudtrail"

  enable_cloudtrail = var.enable_cloudtrail
  trail_name        = var.trail_name
  s3_bucket_name    = var.s3_bucket_name
  sns_topic_name    = var.sns_topic_name
  tags              = var.common_tags
}

# Variables
variable "default_region" {
  description = "Default AWS region for the landing zone"
  type        = string
  default     = "us-east-1"
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail logging"
  type        = bool
  default     = true
}

variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
  default     = "default-cloudtrail"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
  default     = "cloudtrail-logs-bucket"
}

variable "sns_topic_name" {
  description = "SNS topic name for CloudTrail notifications"
  type        = string
  default     = "cloudtrail-notifications"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Hello World"
    Environment = "Production"
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

output "cloudtrail_sns_topic_arn" {
  description = "The ARN of the SNS topic used for CloudTrail notifications"
  value       = module.cloudtrail.sns_topic_arn
}
```

```hcl
# modules/cloudtrail/main.tf
# Module to configure AWS CloudTrail

resource "aws_cloudtrail" "main" {
  count                  = var.enable_cloudtrail ? 1 : 0
  name                   = var.trail_name
  s3_bucket_name         = var.s3_bucket_name
  sns_topic_name         = var.sns_topic_name
  include_global_service_events = true
  is_multi_region_trail  = true
  enable_log_file_validation = true
  tags                   = var.tags
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  count = var.enable_cloudtrail ? 1 : 0
  bucket = var.s3_bucket_name

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

  tags = var.tags
}

resource "aws_sns_topic" "cloudtrail_notifications" {
  count = var.enable_cloudtrail ? 1 : 0
  name  = var.sns_topic_name
  tags  = var.tags
}

# Outputs
output "trail_arn" {
  value = aws_cloudtrail.main[0].arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.cloudtrail_logs[0].bucket
}

output "sns_topic_arn" {
  value = aws_sns_topic.cloudtrail_notifications[0].arn
}
```

```hcl
# modules/cloudtrail/variables.tf
# Variables for the CloudTrail module

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail logging"
  type        = bool
}

variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "sns_topic_name" {
  description = "SNS topic name for CloudTrail notifications"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
```

### Instructions to Apply:
1. Save the main configuration in `main.tf`.
2. Save the module configuration in `modules/cloudtrail/main.tf` and `modules/cloudtrail/variables.tf`.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- Multi-region support is enabled by default for CloudTrail.
- AWS Organizations is not used, so no account management is included.
- Centralized logging is not required, so logs are stored in a single S3 bucket.
- Sensitive data like bucket names and trail names are parameterized for flexibility.