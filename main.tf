```hcl
# main.tf
# This Terraform script sets up a basic AWS Landing Zone with multi-region support, AWS CloudTrail logging, and other configurations based on user inputs.

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

  enable_cloudtrail = var.enable_cloudtrail
  trail_name        = var.trail_name
  s3_bucket_name    = var.cloudtrail_s3_bucket_name
  region            = var.default_region
}

# Multi-region support
module "multi_region_support" {
  source = "./modules/multi-region"

  regions = var.supported_regions
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

variable "cloudtrail_s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
  default     = "cloudtrail-logs-bucket"
}

# Outputs
output "cloudtrail_trail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = module.cloudtrail.trail_arn
}

output "multi_region_status" {
  description = "List of regions where multi-region support is enabled"
  value       = module.multi_region_support.enabled_regions
}

# Instructions:
# 1. Save this script in a file, e.g., `main.tf`.
# 2. Create the `modules/cloudtrail` and `modules/multi-region` directories with their respective configurations.
# 3. Initialize Terraform: `terraform init`.
# 4. Review the plan: `terraform plan`.
# 5. Apply the configuration: `terraform apply`.
# 6. Confirm the changes when prompted.
```

### Module: CloudTrail (`modules/cloudtrail/main.tf`)
```hcl
resource "aws_cloudtrail" "main" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = var.trail_name
  s3_bucket_name                = var.s3_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}

output "trail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main[0].arn
}

variable "enable_cloudtrail" {
  description = "Enable or disable CloudTrail"
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

variable "region" {
  description = "AWS region for CloudTrail"
  type        = string
}
```

### Module: Multi-Region Support (`modules/multi-region/main.tf`)
```hcl
resource "aws_s3_bucket" "multi_region_buckets" {
  for_each = toset(var.regions)

  bucket = "multi-region-bucket-${each.key}"
  acl    = "private"

  tags = {
    Name        = "Multi-Region Bucket"
    Environment = "Landing Zone"
    Region      = each.key
  }
}

output "enabled_regions" {
  description = "List of regions where multi-region support is enabled"
  value       = keys(aws_s3_bucket.multi_region_buckets)
}

variable "regions" {
  description = "List of AWS regions to enable multi-region support"
  type        = list(string)
}
```

### Notes:
1. **Multi-Region Support**: This module creates S3 buckets in all specified regions to demonstrate multi-region support. You can extend this to include other resources as needed.
2. **CloudTrail**: The CloudTrail module enables logging to a specified S3 bucket. Ensure the bucket exists or is created beforehand.
3. **Variables**: Sensitive or environment-specific data is parameterized using variables for flexibility and security.
4. **State Management**: Use a remote backend (e.g., S3 with DynamoDB locking) for production environments to manage Terraform state securely.

### Instructions to Apply:
1. Save the main script and module files in their respective directories.
2. Run `terraform init` to initialize the configuration.
3. Run `terraform plan` to review the changes.
4. Run `terraform apply` to deploy the infrastructure.
5. Confirm the changes when prompted.