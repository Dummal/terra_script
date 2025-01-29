```hcl
# main.tf
# Terraform configuration for setting up an AWS Landing Zone with AWS Organizations and centralized logging.

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
  region = var.aws_region
}

# Module: AWS Organizations
module "aws_organizations" {
  source = "./modules/aws_organizations"

  organization_master_account_email = var.organization_master_account_email
  organization_master_account_name  = var.organization_master_account_name
  tags                              = var.default_tags
}

# Module: Centralized Logging
module "centralized_logging" {
  source = "./modules/centralized_logging"

  logging_account_email = var.logging_account_email
  logging_account_name  = var.logging_account_name
  tags                  = var.default_tags
}

# Variables
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "organization_master_account_email" {
  description = "The email address for the AWS Organizations master account."
  type        = string
}

variable "organization_master_account_name" {
  description = "The name for the AWS Organizations master account."
  type        = string
}

variable "logging_account_email" {
  description = "The email address for the centralized logging account."
  type        = string
}

variable "logging_account_name" {
  description = "The name for the centralized logging account."
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources."
  type        = map(string)
  default = {
    Project     = "Hellop"
    Environment = "Production"
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

### Module: AWS Organizations (`modules/aws_organizations/main.tf`)
```hcl
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_organizations_account" "master_account" {
  email = var.organization_master_account_email
  name  = var.organization_master_account_name
  tags  = var.tags
}

output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = aws_organizations_organization.this.id
}
```

### Module: Centralized Logging (`modules/centralized_logging/main.tf`)
```hcl
resource "aws_organizations_account" "logging_account" {
  email = var.logging_account_email
  name  = var.logging_account_name
  tags  = var.tags
}

output "logging_account_id" {
  description = "The ID of the centralized logging account."
  value       = aws_organizations_account.logging_account.id
}
```

### Variables for Modules (`modules/aws_organizations/variables.tf` and `modules/centralized_logging/variables.tf`)
```hcl
variable "organization_master_account_email" {
  description = "The email address for the AWS Organizations master account."
  type        = string
}

variable "organization_master_account_name" {
  description = "The name for the AWS Organizations master account."
  type        = string
}

variable "logging_account_email" {
  description = "The email address for the centralized logging account."
  type        = string
}

variable "logging_account_name" {
  description = "The name for the centralized logging account."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
}
```

### Instructions to Apply
1. Save the main script in `main.tf` and the module files in their respective directories (`modules/aws_organizations` and `modules/centralized_logging`).
2. Create a `terraform.tfvars` file to provide values for the variables:
   ```hcl
   organization_master_account_email = "hshgdhjsghdgsjgjds"
   organization_master_account_name  = "sdjshdjhsgjhdgs"
   logging_account_email             = "logging@example.com"
   logging_account_name              = "CentralizedLogging"
   ```
3. Run the following commands:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
4. Confirm the changes when prompted.

### Assumptions
- AWS Organizations is enabled in the account.
- The email addresses provided are valid and not already associated with existing AWS accounts.
- Centralized logging is limited to a single account for simplicity.