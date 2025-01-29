```hcl
# main.tf
# Terraform script to create a multi-region AWS Landing Zone with AWS Organizations, CloudTrail, and centralized logging.

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
  default     = "Hello1234" # Replace with your organization name
}

variable "default_region" {
  description = "The default AWS region for the landing zone."
  type        = string
  default     = "us-east-1"
}

variable "enable_multi_region" {
  description = "Enable multi-region support for the landing zone."
  type        = bool
  default     = true
}

variable "enable_aws_organizations" {
  description = "Enable AWS Organizations for account management."
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

variable "landingzone_username" {
  description = "The username for the landing zone."
  type        = string
  default     = "Hello1234"
}

variable "landingzone_email" {
  description = "The email address for the landing zone."
  type        = string
  default     = "hello1234@example.com"
}

# AWS Organizations
module "aws_organizations" {
  source = "./modules/aws_organizations"

  enable_aws_organizations = var.enable_aws_organizations
  organization_name        = var.organization_name
  landingzone_email        = var.landingzone_email
}

# CloudTrail
module "cloudtrail" {
  source = "./modules/cloudtrail"

  enable_cloudtrail = var.enable_cloudtrail
  organization_name = var.organization_name
  default_region    = var.default_region
}

# Centralized Logging
module "centralized_logging" {
  source = "./modules/centralized_logging"

  centralize_logs = var.centralize_logs
  organization_name = var.organization_name
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = module.aws_organizations.organization_id
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail."
  value       = module.cloudtrail.cloudtrail_arn
}

output "logging_bucket_name" {
  description = "The name of the centralized logging S3 bucket."
  value       = module.centralized_logging.logging_bucket_name
}
```

### Modules

#### `modules/aws_organizations/main.tf`
```hcl
resource "aws_organizations_organization" "this" {
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
}

output "organization_id" {
  value = aws_organizations_organization.this.id
}
```

#### `modules/cloudtrail/main.tf`
```hcl
resource "aws_cloudtrail" "this" {
  name                          = "${var.organization_name}-cloudtrail"
  s3_bucket_name                = "${var.organization_name}-cloudtrail-logs"
  include_global_service_events = true
  is_multi_region_trail         = var.enable_multi_region
  enable_log_file_validation    = true
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.this.arn
}
```

#### `modules/centralized_logging/main.tf`
```hcl
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.organization_name}-centralized-logs"
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
    Name        = "${var.organization_name}-centralized-logs"
    Environment = "Production"
  }
}

output "logging_bucket_name" {
  value = aws_s3_bucket.logging_bucket.id
}
```

### Instructions to Apply
1. Save the main script in `main.tf` and the module scripts in their respective directories (`modules/aws_organizations`, `modules/cloudtrail`, `modules/centralized_logging`).
2. Initialize Terraform: `terraform init`.
3. Review the plan: `terraform plan`.
4. Apply the configuration: `terraform apply`.
5. Confirm the changes when prompted.

This configuration creates a multi-region AWS Landing Zone with AWS Organizations, CloudTrail, and centralized logging. It uses modules for better organization and reusability. Adjust the variables as needed for your environment.