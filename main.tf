```hcl
# main.tf
# Terraform script to create an AWS Landing Zone with centralized logging and AWS Organizations

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

# AWS Organizations setup
resource "aws_organizations_organization" "main" {
  feature_set = "ALL"

  # Tags for resource identification
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# Centralized logging account
module "logging_account" {
  source = "./modules/logging_account"

  account_name  = "LoggingAccount"
  email_address = var.logging_account_email
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project or organization"
  type        = string
  default     = "default_project"
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "logging_account_email" {
  description = "Email address for the logging account"
  type        = string
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.main.id
}

output "logging_account_id" {
  description = "The ID of the centralized logging account"
  value       = module.logging_account.account_id
}
```

### Module: Logging Account (`modules/logging_account/main.tf`)
```hcl
# Module to create a logging account in AWS Organizations

resource "aws_organizations_account" "logging" {
  name  = var.account_name
  email = var.email_address

  # Tags for resource identification
  tags = var.tags
}

# Outputs
output "account_id" {
  description = "The ID of the logging account"
  value       = aws_organizations_account.logging.id
}
```

### Module: Logging Account (`modules/logging_account/variables.tf`)
```hcl
variable "account_name" {
  description = "Name of the logging account"
  type        = string
}

variable "email_address" {
  description = "Email address for the logging account"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the logging account"
  type        = map(string)
}
```

### Module: Logging Account (`modules/logging_account/outputs.tf`)
```hcl
output "account_id" {
  description = "The ID of the logging account"
  value       = aws_organizations_account.logging.id
}
```

### Instructions to Apply
1. Save the main script in a file named `main.tf`.
2. Create a folder named `modules/logging_account` and save the module files (`main.tf`, `variables.tf`, `outputs.tf`) inside it.
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Review the plan:
   ```bash
   terraform plan -var="logging_account_email=<your_logging_account_email>"
   ```
5. Apply the configuration:
   ```bash
   terraform apply -var="logging_account_email=<your_logging_account_email>"
   ```
6. Confirm the changes when prompted.

### Assumptions
- AWS Organizations is enabled in the account.
- The email address for the logging account is provided as a variable (`logging_account_email`).
- Multi-region support is not required, so the resources are deployed in a single region (`us-east-1` by default).
- AWS CloudTrail logging is not enabled as per the user input. This can be added later if needed.