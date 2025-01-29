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

# Variables
variable "organization_name" {
  description = "The name of the organization or project."
  type        = string
}

variable "landing_zone_username" {
  description = "The username for the landing zone."
  type        = string
}

variable "landing_zone_email" {
  description = "The email address for the landing zone."
  type        = string
}

variable "default_region" {
  description = "The default AWS region for the landing zone."
  type        = string
  default     = "us-east-1"
}

variable "enable_multi_region_support" {
  description = "Enable multi-region support for the landing zone."
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail logging services."
  type        = bool
  default     = true
}

variable "centralize_logs" {
  description = "Centralize logs from all accounts into the logging account."
  type        = bool
  default     = true
}

# AWS Organizations
module "aws_organizations" {
  source = "./modules/aws_organizations"

  organization_name = var.organization_name
  landing_zone_email = var.landing_zone_email
}

# AWS CloudTrail
module "aws_cloudtrail" {
  source = "./modules/aws_cloudtrail"

  enable_cloudtrail = var.enable_cloudtrail
  centralize_logs   = var.centralize_logs
  default_region    = var.default_region
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = module.aws_organizations.organization_id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = module.aws_cloudtrail.cloudtrail_arn
}
```

### Modules

#### `modules/aws_organizations/main.tf`
```hcl
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  tags = {
    Name        = var.organization_name
    Environment = "Production"
  }
}

output "organization_id" {
  value = aws_organizations_organization.this.id
}
```

#### `modules/aws_cloudtrail/main.tf`
```hcl
resource "aws_cloudtrail" "this" {
  name                          = "landing-zone-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  is_multi_region_trail         = var.enable_cloudtrail
  enable_log_file_validation    = true
  include_global_service_events = true

  tags = {
    Name        = "LandingZoneCloudTrail"
    Environment = "Production"
  }
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "landing-zone-cloudtrail-logs-${random_id.suffix.hex}"

  tags = {
    Name        = "CloudTrailLogs"
    Environment = "Production"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.this.arn
}
```

### Instructions to Apply
1. Save the main script in `main.tf` and the module scripts in their respective directories (`modules/aws_organizations` and `modules/aws_cloudtrail`).
2. Initialize Terraform: `terraform init`.
3. Review the plan: `terraform plan`.
4. Apply the configuration: `terraform apply`.
5. Confirm the changes when prompted.