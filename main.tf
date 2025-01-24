```hcl
# main.tf
# This Terraform script creates an AWS Organizational Unit (OU) and applies Service Control Policies (SCPs) to it.
# Assumptions:
# - AWS provider is used.
# - The user will provide the organization ID, OU name, and SCP details as variables.

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create an Organizational Unit (OU)
resource "aws_organizations_organizational_unit" "example_ou" {
  name            = var.ou_name
  parent_id       = var.organization_id

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Apply Service Control Policies (SCPs) to the OU
resource "aws_organizations_policy_attachment" "scp_attachment" {
  for_each = toset(var.scp_ids)

  policy_id = each.value
  target_id = aws_organizations_organizational_unit.example_ou.id
}

# Variables
variable "aws_region" {
  description = "The AWS region to use."
  type        = string
  default     = "us-east-1"
}

variable "organization_id" {
  description = "The ID of the AWS Organization."
  type        = string
}

variable "ou_name" {
  description = "The name of the Organizational Unit (OU)."
  type        = string
}

variable "scp_ids" {
  description = "A list of Service Control Policy (SCP) IDs to attach to the OU."
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "The environment tag for the resources (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

# Outputs
output "ou_id" {
  description = "The ID of the created Organizational Unit (OU)."
  value       = aws_organizations_organizational_unit.example_ou.id
}

output "ou_arn" {
  description = "The ARN of the created Organizational Unit (OU)."
  value       = aws_organizations_organizational_unit.example_ou.arn
}

# Instructions to Apply:
# 1. Save this script in a file, e.g., `main.tf`.
# 2. Create a `terraform.tfvars` file to provide values for variables like `organization_id`, `ou_name`, and `scp_ids`.
# 3. Initialize Terraform: `terraform init`.
# 4. Review the plan: `terraform plan`.
# 5. Apply the configuration: `terraform apply`.
# 6. Confirm the changes when prompted.
```

### Example `terraform.tfvars` File:
```hcl
aws_region      = "us-east-1"
organization_id = "o-xxxxxxxxxx"
ou_name         = "ExampleOU"
scp_ids         = ["p-xxxxxxxxxx", "p-yyyyyyyyyy"]
environment     = "prod"
```

### Notes:
1. Replace `organization_id`, `ou_name`, and `scp_ids` with actual values in the `terraform.tfvars` file.
2. The script assumes that the AWS Organization and SCPs already exist.
3. Tags are added to the OU for better resource management. Adjust as needed.