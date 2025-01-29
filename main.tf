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

  organization_name = var.organization_name
  admin_email       = var.admin_email
}

# Module: CloudTrail
module "cloudtrail" {
  source = "./modules/cloudtrail"

  enable_cloudtrail = var.enable_cloudtrail
  log_bucket_name   = var.log_bucket_name
}

# Module: Centralized Logging
module "centralized_logging" {
  source = "./modules/centralized_logging"

  log_bucket_name = var.log_bucket_name
  regions         = var.regions
}

# Variables
variable "organization_name" {
  description = "The name of the AWS Organization or project."
  type        = string
}

variable "admin_email" {
  description = "The email address for the AWS Organization administrator."
  type        = string
}

variable "default_region" {
  description = "The default AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "regions" {
  description = "List of AWS regions for multi-region support."
  type        = list(string)
  default     = ["us-east-1", "us-west-1"]
}

variable "enable_cloudtrail" {
  description = "Flag to enable AWS CloudTrail logging services."
  type        = bool
  default     = true
}

variable "log_bucket_name" {
  description = "The S3 bucket name for storing CloudTrail logs."
  type        = string
  default     = "centralized-logs-bucket"
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

output "log_bucket_arn" {
  description = "The ARN of the centralized logging S3 bucket."
  value       = module.centralized_logging.log_bucket_arn
}
```

### Modules

#### Module: `aws_organizations`
```hcl
# modules/aws_organizations/main.tf
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_organizations_account" "admin_account" {
  name  = var.organization_name
  email = var.admin_email
}

output "organization_id" {
  value = aws_organizations_organization.this.id
}
```

#### Module: `cloudtrail`
```hcl
# modules/cloudtrail/main.tf
resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket_name
  acl    = "private"

  tags = {
    Name        = "CloudTrailLogs"
    Environment = "Production"
  }
}

resource "aws_cloudtrail" "this" {
  name                          = "cloudtrail"
  s3_bucket_name                = aws_s3_bucket.log_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.this.arn
}
```

#### Module: `centralized_logging`
```hcl
# modules/centralized_logging/main.tf
resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket_name
  acl    = "private"

  tags = {
    Name        = "CentralizedLogs"
    Environment = "Production"
  }
}

output "log_bucket_arn" {
  value = aws_s3_bucket.log_bucket.arn
}
```

### Instructions to Apply
1. Save the main script in `main.tf` and the module scripts in their respective directories.
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the plan:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```
5. Confirm the changes when prompted.

### Assumptions
- The organization name and admin email are provided as inputs.
- Multi-region support is enabled by default for `us-east-1` and `us-west-1`.
- CloudTrail and centralized logging are enabled by default.
- S3 bucket names are customizable via variables.