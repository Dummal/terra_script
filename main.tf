```hcl
# main.tf
# This Terraform script sets up a multi-region AWS Landing Zone with AWS Organizations, CloudTrail, and centralized logging.

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

# Module: AWS Organizations
module "aws_organizations" {
  source = "./modules/aws_organizations"

  organization_master_account_email = var.organization_master_account_email
  organization_master_account_name  = var.organization_master_account_name
  tags                              = var.common_tags
}

# Module: CloudTrail
module "cloudtrail" {
  source = "./modules/cloudtrail"

  enable_cloudtrail = var.enable_cloudtrail
  logs_bucket_name  = var.logs_bucket_name
  tags              = var.common_tags
}

# Module: Centralized Logging
module "centralized_logging" {
  source = "./modules/centralized_logging"

  enable_centralized_logging = var.enable_centralized_logging
  logs_bucket_name           = var.logs_bucket_name
  tags                       = var.common_tags
}

# Variables
variable "default_region" {
  description = "Default AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "organization_master_account_email" {
  description = "Email address for the AWS Organizations master account"
  type        = string
}

variable "organization_master_account_name" {
  description = "Name for the AWS Organizations master account"
  type        = string
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail logging"
  type        = bool
  default     = true
}

variable "enable_centralized_logging" {
  description = "Enable centralized logging for all accounts"
  type        = bool
  default     = true
}

variable "logs_bucket_name" {
  description = "S3 bucket name for storing logs"
  type        = string
  default     = "landing-zone-logs"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "LandingZone"
    Environment = "Production"
  }
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = module.aws_organizations.organization_id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail"
  value       = module.cloudtrail.cloudtrail_arn
}

output "logs_bucket_arn" {
  description = "The ARN of the centralized logging S3 bucket"
  value       = module.centralized_logging.logs_bucket_arn
}
```

### Modules

#### Module: `aws_organizations`
```hcl
# modules/aws_organizations/main.tf
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_organizations_account" "master_account" {
  email = var.organization_master_account_email
  name  = var.organization_master_account_name
  tags  = var.tags
}

output "organization_id" {
  value = aws_organizations_organization.this.id
}
```

#### Module: `cloudtrail`
```hcl
# modules/cloudtrail/main.tf
resource "aws_s3_bucket" "logs" {
  bucket = var.logs_bucket_name
  acl    = "private"

  tags = var.tags
}

resource "aws_cloudtrail" "this" {
  name                          = "landing-zone-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  tags = var.tags
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.this.arn
}
```

#### Module: `centralized_logging`
```hcl
# modules/centralized_logging/main.tf
resource "aws_s3_bucket" "logs" {
  bucket = var.logs_bucket_name
  acl    = "private"

  tags = var.tags
}

output "logs_bucket_arn" {
  value = aws_s3_bucket.logs.arn
}
```

### Instructions to Apply
1. Save the main script in `main.tf` and the modules in their respective directories (`modules/aws_organizations`, `modules/cloudtrail`, `modules/centralized_logging`).
2. Initialize Terraform: `terraform init`.
3. Review the plan: `terraform plan`.
4. Apply the configuration: `terraform apply`.
5. Confirm the changes when prompted.

### Assumptions
- The user has provided valid email and name for the AWS Organizations master account.
- The S3 bucket name for logs is unique across AWS.
- Multi-region support is enabled by default for CloudTrail.