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
  description = "The name of the Organizational Unit (OU)"
  type        = string
}

variable "parent_id" {
  description = "The ID of the parent organizational unit or root"
  type        = string
}

variable "scp_policies" {
  description = "List of Service Control Policies (SCPs) to attach to the OU"
  type        = list(object({
    name        = string
    description = string
    content     = string
  }))
  default = []
}

# Resource: Create Organizational Unit
resource "aws_organizations_organizational_unit" "this" {
  name     = var.organization_unit_name
  parent_id = var.parent_id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Resource: Create and Attach SCPs
resource "aws_organizations_policy" "scp" {
  for_each    = { for policy in var.scp_policies : policy.name => policy }
  name        = each.value.name
  description = each.value.description
  content     = each.value.content
  type        = "SERVICE_CONTROL_POLICY"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_organizations_policy_attachment" "scp_attachment" {
  for_each = { for policy in var.scp_policies : policy.name => policy }
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
  value       = [for policy in aws_organizations_policy.scp : policy.id]
}
```

### Instructions to Apply:
1. Save the script in a file, e.g., `main.tf`.
2. Create a `variables.tf` file to define and customize variables if needed.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
1. The `parent_id` is provided and valid (either a root ID or an existing OU ID).
2. SCPs are optional. If no SCPs are provided, only the OU will be created.
3. The `scp_policies` variable expects a list of objects with `name`, `description`, and `content` fields for each SCP.

### Example `terraform.tfvars`:
```hcl
aws_region = "us-east-1"
organization_unit_name = "ExampleOU"
parent_id = "r-examplerootid"
scp_policies = [
  {
    name        = "DenyAllExceptS3",
    description = "Deny all actions except S3 access",
    content     = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "NotAction": "s3:*",
      "Resource": "*"
    }
  ]
}
EOT
  }
]
```

This script is modular, reusable, and adheres to Terraform best practices. It allows for the creation of an AWS Organizational Unit and the optional attachment of Service Control Policies.