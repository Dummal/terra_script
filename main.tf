```hcl
# main.tf
# This Terraform script sets up a basic AWS Landing Zone with multi-region support and CloudTrail logging enabled.

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
module "cloudtrail" {
  source = "./modules/cloudtrail"

  enable_logging = true
  trail_name     = var.cloudtrail_name
  s3_bucket_name = var.cloudtrail_s3_bucket_name
  regions        = var.supported_regions
}

# Variables
variable "default_region" {
  description = "The default AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "supported_regions" {
  description = "List of AWS regions to enable multi-region support"
  type        = list(string)
  default     = ["us-east-1", "us-west-1", "us-west-2"]
}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
  default     = "landingzone-cloudtrail"
}

variable "cloudtrail_s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
  default     = "landingzone-cloudtrail-logs"
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

# Instructions:
# 1. Save this script in a file named `main.tf`.
# 2. Create a `modules/cloudtrail` directory and add the CloudTrail module code (see below).
# 3. Run `terraform init` to initialize the configuration.
# 4. Run `terraform plan` to review the changes.
# 5. Run `terraform apply` to apply the configuration.
```

```hcl
# modules/cloudtrail/main.tf
# This module sets up AWS CloudTrail with multi-region support.

resource "aws_cloudtrail" "main" {
  name                          = var.trail_name
  s3_bucket_name                = var.s3_bucket_name
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true
  is_organization_trail         = false

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = var.tags
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = var.s3_bucket_name

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

  tags = var.tags
}

# Variables
variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    Environment = "LandingZone"
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "trail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket used for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}
```

### Key Assumptions:
1. AWS Organizations is not used, so the `is_organization_trail` is set to `false`.
2. Multi-region support is enabled for CloudTrail.
3. Logs are stored in an S3 bucket with server-side encryption enabled.
4. Default regions are `us-east-1`, `us-west-1`, and `us-west-2`. You can override these using the `supported_regions` variable.

### Instructions to Apply:
1. Save the `main.tf` file in your working directory.
2. Create a `modules/cloudtrail` directory and save the module code in a `main.tf` file inside it.
3. Run `terraform init` to initialize the configuration.
4. Run `terraform plan` to review the changes.
5. Run `terraform apply` to apply the configuration. Confirm the changes when prompted.