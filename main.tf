```hcl
# main.tf
# Terraform configuration for setting up an AWS Organization with modular design

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

# Module for AWS Organization
module "aws_organization" {
  source = "./modules/aws_organization"

  organization_features = var.organization_features
  policy_types          = var.policy_types
  organizational_units  = var.organizational_units
  tags                  = var.tags
}

# Module for custom policies
module "custom_policies" {
  source = "./modules/custom_policies"

  create_custom_policies = var.create_custom_policies
  policies               = var.policies
}

# Outputs
output "organization_id" {
  value       = module.aws_organization.organization_id
  description = "The ID of the AWS Organization"
}

output "organizational_units" {
  value       = module.aws_organization.organizational_units
  description = "List of created Organizational Units"
}
```

```hcl
# variables.tf
# Define variables for the AWS Organization setup

variable "aws_region" {
  description = "The AWS region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

variable "organization_features" {
  description = "The features to enable for the AWS Organization (e.g., ALL or CONSOLIDATED_BILLING)"
  type        = string
  default     = "ALL"
}

variable "policy_types" {
  description = "List of policy types to enable in the organization (e.g., SERVICE_CONTROL_POLICY, TAG_POLICY)"
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY"]
}

variable "organizational_units" {
  description = "List of organizational units to create within the AWS Organization"
  type        = list(object({
    name = string
    tags = map(string)
  }))
  default = [
    {
      name = "Security"
      tags = {
        Environment = "Production"
        Purpose     = "Security"
      }
    },
    {
      name = "AuditLog"
      tags = {
        Environment = "Production"
        Purpose     = "Audit"
      }
    }
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Project     = "AWS Organization Setup"
    Environment = "Production"
  }
}

variable "create_custom_policies" {
  description = "Whether to create custom policies"
  type        = bool
  default     = false
}

variable "policies" {
  description = "List of custom policies to create"
  type        = list(object({
    name        = string
    description = string
    content     = string
    target_id   = string
  }))
  default = []
}
```

```hcl
# modules/aws_organization/main.tf
# Module for creating AWS Organization and Organizational Units

resource "aws_organizations_organization" "this" {
  feature_set = var.organization_features
}

resource "aws_organizations_policy_type" "this" {
  for_each = toset(var.policy_types)

  policy_type = each.value
  root_id     = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "this" {
  for_each = { for ou in var.organizational_units : ou.name => ou }

  name      = each.key
  parent_id = aws_organizations_organization.this.roots[0].id
  tags      = each.value.tags
}

output "organization_id" {
  value = aws_organizations_organization.this.id
}

output "organizational_units" {
  value = aws_organizations_organizational_unit.this
}
```

```hcl
# modules/custom_policies/main.tf
# Module for creating custom policies

resource "aws_organizations_policy" "this" {
  count       = var.create_custom_policies ? length(var.policies) : 0
  name        = var.policies[count.index].name
  description = var.policies[count.index].description
  content     = var.policies[count.index].content
  type        = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "this" {
  count     = var.create_custom_policies ? length(var.policies) : 0
  policy_id = aws_organizations_policy.this[count.index].id
  target_id = var.policies[count.index].target_id
}
```

### Instructions to Apply:
1. Save the main script in `main.tf` and the modules in their respective directories (`modules/aws_organization` and `modules/custom_policies`).
2. Initialize Terraform: `terraform init`.
3. Review the plan: `terraform plan`.
4. Apply the configuration: `terraform apply`.
5. Confirm the changes when prompted.

### Assumptions:
- The AWS Organization is being created from scratch.
- Default values are provided for features, policy types, and organizational units.
- Custom policies are optional and can be enabled by setting `create_custom_policies` to `true`.