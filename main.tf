```hcl
# main.tf
# This Terraform script sets up an AWS Organization with centralized logging.
# Assumptions:
# - AWS Organizations is enabled.
# - Centralized logging is required.
# - CloudTrail logging is not enabled as per user input.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# Module: AWS Organizations
module "aws_organizations" {
  source = "./modules/aws_organizations"

  organization_name = var.organization_name
  admin_email       = var.admin_email
  username          = var.username
  tags              = var.default_tags
}

# Module: Centralized Logging
module "centralized_logging" {
  source = "./modules/centralized_logging"

  logging_account_email = var.logging_account_email
  tags                  = var.default_tags
}

# Variables
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "organization_name" {
  description = "The name of the AWS Organization."
  type        = string
  default     = "Hello123"
}

variable "admin_email" {
  description = "The email address for the AWS Organization admin account."
  type        = string
  default     = "Hello"
}

variable "username" {
  description = "The username for the landing zone."
  type        = string
  default     = "Hello"
}

variable "logging_account_email" {
  description = "The email address for the centralized logging account."
  type        = string
  default     = "logs@example.com"
}

variable "default_tags" {
  description = "Default tags to apply to all resources."
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "LandingZone"
  }
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = module.aws_organizations.organization_id
}

output "logging_account_id" {
  description = "The ID of the centralized logging account."
  value       = module.centralized_logging.logging_account_id
}
```

```hcl
# modules/aws_organizations/main.tf
# This module sets up an AWS Organization.

resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_organizations_account" "admin_account" {
  name      = var.organization_name
  email     = var.admin_email
  role_name = "OrganizationAccountAccessRole"
  tags      = var.tags
}

output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = aws_organizations_organization.this.id
}
```

```hcl
# modules/aws_organizations/variables.tf
variable "organization_name" {
  description = "The name of the AWS Organization."
  type        = string
}

variable "admin_email" {
  description = "The email address for the AWS Organization admin account."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the AWS Organization resources."
  type        = map(string)
}
```

```hcl
# modules/centralized_logging/main.tf
# This module sets up a centralized logging account.

resource "aws_organizations_account" "logging_account" {
  name      = "CentralizedLogging"
  email     = var.logging_account_email
  role_name = "OrganizationAccountAccessRole"
  tags      = var.tags
}

output "logging_account_id" {
  description = "The ID of the centralized logging account."
  value       = aws_organizations_account.logging_account.id
}
```

```hcl
# modules/centralized_logging/variables.tf
variable "logging_account_email" {
  description = "The email address for the centralized logging account."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the centralized logging account."
  type        = map(string)
}
```

### Instructions to Apply:
1. Save the main script in `main.tf` and the module files in their respective directories (`modules/aws_organizations` and `modules/centralized_logging`).
2. Initialize Terraform: `terraform init`.
3. Review the plan: `terraform plan`.
4. Apply the configuration: `terraform apply`.
5. Confirm the changes when prompted.

### Notes:
- The `logging_account_email` variable should be updated with the actual email address for the logging account.
- Ensure that the AWS credentials used have the necessary permissions to create AWS Organizations and accounts.