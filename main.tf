```hcl
# Terraform script to create an AWS Organizational Unit (OU) with optional Service Control Policies (SCPs)

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

# Variables
variable "aws_region" {
  description = "The AWS region to use for the provider"
  type        = string
  default     = "us-east-1"
}

variable "organization_unit_name" {
  description = "The name of the Organizational Unit (OU) to create"
  type        = string
}

variable "parent_ou_id" {
  description = "The ID of the parent Organizational Unit or root under which the new OU will be created"
  type        = string
}

variable "scp_policies" {
  description = "List of Service Control Policies (SCPs) to attach to the Organizational Unit"
  type        = list(object({
    name        = string
    description = string
    policy      = string
  }))
  default = []
}

# Resource: Create Organizational Unit
resource "aws_organizations_organizational_unit" "this" {
  name      = var.organization_unit_name
  parent_id = var.parent_ou_id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Resource: Create and Attach SCPs
resource "aws_organizations_policy" "scp" {
  for_each    = { for scp in var.scp_policies : scp.name => scp }
  name        = each.value.name
  description = each.value.description
  content     = each.value.policy
  type        = "SERVICE_CONTROL_POLICY"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_organizations_policy_attachment" "scp_attachment" {
  for_each = { for scp in var.scp_policies : scp.name => scp }
  policy_id = aws_organizations_policy.scp[each.key].id
  target_id = aws_organizations_organizational_unit.this.id
}

# Outputs
output "organizational_unit_id" {
  description = "The ID of the created Organizational Unit"
  value       = aws_organizations_organizational_unit.this.id
}

output "scp_policy_ids" {
  description = "The IDs of the attached Service Control Policies (SCPs)"
  value       = [for scp in aws_organizations_policy.scp : scp.id]
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file to define and override variables if needed.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- The `parent_ou_id` is provided and valid.
- SCP policies are optional. If no SCPs are provided, only the OU will be created.
- The `scp_policies` variable expects a list of objects with `name`, `description`, and `policy` fields. The `policy` field should contain the JSON policy as a string.

### Example `terraform.tfvars`:
```hcl
aws_region = "us-east-1"
organization_unit_name = "ExampleOU"
parent_ou_id = "r-examplerootid"
scp_policies = [
  {
    name        = "DenyAllExceptBilling"
    description = "Deny all actions except billing"
    policy      = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "NotAction": "aws-portal:*Billing",
      "Resource": "*"
    }
  ]
}
EOT
  }
]
```

This script is modular, reusable, and adheres to Terraform best practices. It allows for the creation of an AWS Organizational Unit and the optional attachment of Service Control Policies.