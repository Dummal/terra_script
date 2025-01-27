```hcl
# main.tf
# This Terraform script sets up an AWS Organization with modular configurations for features, OUs, policies, and tags.

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

# Module: AWS Organization
module "aws_organization" {
  source = "./modules/organization"

  organization_features = var.organization_features
  policy_types          = var.policy_types
  organizational_units  = var.organizational_units
  tags                  = var.tags
}

# Module: Custom Policies
module "custom_policies" {
  source = "./modules/custom_policies"

  create_custom_policies = var.create_custom_policies
  policies               = var.policies
}

# Outputs
output "organization_id" {
  value       = module.aws_organization.organization_id
  description = "The ID of the AWS Organization."
}

output "organizational_units" {
  value       = module.aws_organization.organizational_units
  description = "List of created Organizational Units."
}
```

```hcl
# variables.tf
# Define variables for the AWS Organization setup.

variable "aws_region" {
  description = "The AWS region to use for the provider."
  type        = string
  default     = "us-east-1"
}

variable "organization_features" {
  description = "The features to enable for the AWS Organization (e.g., ALL or CONSOLIDATED_BILLING)."
  type        = string
  default     = "ALL"
}

variable "policy_types" {
  description = "List of policy types to enable in the organization (e.g., SERVICE_CONTROL_POLICY, TAG_POLICY)."
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY"]
}

variable "organizational_units" {
  description = "List of organizational units to create within the AWS Organization."
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
  description = "Tags to apply to all resources created by this configuration."
  type        = map(string)
  default     = {
    Project     = "AWS Organization Setup"
    Environment = "Production"
  }
}

variable "create_custom_policies" {
  description = "Whether to create custom policies for the organization."
  type        = bool
  default     = false
}

variable "policies" {
  description = "List of custom policies to create, including their name, purpose, content, and attachment targets."
  type = list(object({
    name    = string
    purpose = string
    content = string
    targets = list(string)
  }))
  default = []
}
```

```hcl
# modules/organization/main.tf
# Module to create AWS Organization, enable features, and create OUs.

resource "aws_organizations_organization" "this" {
  feature_set = var.organization_features
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each = { for ou in var.organizational_units : ou.name => ou }

  name      = each.value.name
  parent_id = aws_organizations_organization.this.id
  tags      = each.value.tags
}

output "organization_id" {
  value = aws_organizations_organization.this.id
}

output "organizational_units" {
  value = aws_organizations_organizational_unit.ou
}
```

```hcl
# modules/custom_policies/main.tf
# Module to create custom policies and attach them to targets.

resource "aws_organizations_policy" "custom_policy" {
  for_each = { for policy in var.policies : policy.name => policy }

  name     = each.value.name
  type     = "SERVICE_CONTROL_POLICY"
  content  = each.value.content
  tags     = {
    Purpose = each.value.purpose
  }
}

resource "aws_organizations_policy_attachment" "policy_attachment" {
  for_each = { for policy in var.policies : policy.name => policy }

  policy_id = aws_organizations_policy.custom_policy[each.key].id
  target_id = each.value.targets[0] # Assuming one target per policy for simplicity
}
```

```hcl
# outputs.tf
# Outputs for the main configuration.

output "organization_id" {
  value       = module.aws_organization.organization_id
  description = "The ID of the AWS Organization."
}

output "organizational_units" {
  value       = module.aws_organization.organizational_units
  description = "List of created Organizational Units."
}
```

### Instructions to Apply:
1. Save the scripts in appropriate files (`main.tf`, `variables.tf`, `outputs.tf`, and module files).
2. Initialize Terraform: `terraform init`.
3. Review the plan: `terraform plan`.
4. Apply the configuration: `terraform apply`.
5. Confirm the changes when prompted.

### Assumptions:
- The AWS Organization is being created from scratch.
- Default values are provided for features, OUs, and tags.
- Custom policies are optional and can be enabled via `create_custom_policies`.