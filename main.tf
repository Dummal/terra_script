```hcl
# main.tf
# This Terraform script sets up an AWS Organizational Unit (OU) with optional Service Control Policies (SCPs).
# Assumptions:
# - AWS provider is used.
# - Users or roles managing the OU will have permissions defined externally.
# - SCPs are optional and can be defined via variables.

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
  name      = var.ou_name
  parent_id = var.parent_id

  tags = var.tags
}

# Optional: Attach Service Control Policies (SCPs) to the OU
resource "aws_organizations_policy_attachment" "scp_attachment" {
  count      = length(var.scp_ids) > 0 ? length(var.scp_ids) : 0
  policy_id  = var.scp_ids[count.index]
  target_id  = aws_organizations_organizational_unit.example_ou.id
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
  description = "List of Service Control Policy (SCP) IDs to attach to the OU."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the Organizational Unit."
  type        = map(string)
  default     = {}
}

# Outputs
output "ou_id" {
  description = "The ID of the created Organizational Unit."
  value       = aws_organizations_organizational_unit.example_ou.id
}

output "ou_arn" {
  description = "The ARN of the created Organizational Unit."
  value       = aws_organizations_organizational_unit.example_ou.arn
}

# Instructions to Apply:
# 1. Save this script in a file, e.g., `main.tf`.
# 2. Create a `terraform.tfvars` file to define the required variables (e.g., `ou_name`, `parent_id`).
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
tags = {
  Environment = "Production"
  Team        = "DevOps"
}
```

### Notes:
1. **Access Management**: The script assumes that users or roles managing the OU have the necessary permissions defined outside of this configuration.
2. **Service Control Policies (SCPs)**: SCPs are optional. If no SCPs are provided, the `aws_organizations_policy_attachment` resource will not be created.
3. **Tags**: Tags are optional but recommended for resource organization and cost tracking.
4. **Parent ID**: Ensure the `parent_id` corresponds to a valid root or OU ID in your AWS Organization.