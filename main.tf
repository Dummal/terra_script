```hcl
# main.tf
# This Terraform script creates an AWS Organizational Unit (OU) and applies Service Control Policies (SCPs) to it.
# Assumptions:
# - AWS provider is used.
# - SCPs and OU names are provided as variables for flexibility.
# - Users or roles managing the OU are assumed to have IAM permissions.

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

# Create an Organizational Unit (OU) in AWS Organizations
resource "aws_organizations_organizational_unit" "example_ou" {
  name      = var.ou_name
  parent_id = var.parent_id

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

variable "ou_name" {
  description = "The name of the Organizational Unit (OU)."
  type        = string
}

variable "parent_id" {
  description = "The ID of the parent Organizational Unit or root."
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
# 2. Create a `terraform.tfvars` file to define the required variables (e.g., ou_name, parent_id, scp_ids).
# 3. Initialize Terraform: `terraform init`.
# 4. Review the plan: `terraform plan`.
# 5. Apply the configuration: `terraform apply`.
# 6. Confirm the changes when prompted.
```

### Example `terraform.tfvars` File
```hcl
aws_region = "us-east-1"
ou_name    = "ExampleOU"
parent_id  = "r-examplerootid"
scp_ids    = ["p-examplepolicyid1", "p-examplepolicyid2"]
environment = "prod"
```

### Notes:
1. Replace `parent_id` with the ID of the root or parent OU where the new OU should be created.
2. Replace `scp_ids` with the IDs of the SCPs you want to attach to the OU.
3. Ensure the AWS credentials used have sufficient permissions to manage AWS Organizations and SCPs.