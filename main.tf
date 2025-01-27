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

# Module to create AWS Organization
module "aws_organization" {
  source = "./modules/aws_organization"

  organization_features = var.organization_features
  policy_types          = var.policy_types
  organizational_units  = var.organizational_units
  tags                  = var.tags
}

# Module to create custom policies
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
# Define input variables for the Terraform configuration

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
  type        = list(string)
  default     = ["Security", "AuditLog"]
}

variable "tags" {
  description = "Tags to assign to each organizational unit"
  type        = map(string)
  default     = {
    Environment = "Production"
    Purpose     = "Security"
  }
}

variable "create_custom_policies" {
  description = "Whether to create custom policies for the organization"
  type        = bool
  default     = false
}

variable "policies" {
  description = "List of custom policies to create, including name, purpose, content, and attachment targets"
  type = list(object({
    name    = string
    purpose = string
    content = string
    target  = string
  }))
  default = []
}
```

```hcl
# outputs.tf
# Define outputs for the Terraform configuration

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
# modules/aws_organization/main.tf
# Module to create AWS Organization and Organizational Units

resource "aws_organizations_organization" "this" {
  feature_set = var.organization_features
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each = toset(var.organizational_units)

  name      = each.value
  parent_id = aws_organizations_organization.this.id
  tags      = var.tags
}

output "organization_id" {
  value = aws_organizations_organization.this.id
}

output "organizational_units" {
  value = [for ou in aws_organizations_organizational_unit.ou : ou.name]
}
```

```hcl
# modules/aws_organization/variables.tf
# Variables for the AWS Organization module

variable "organization_features" {
  description = "The features to enable for the AWS Organization (e.g., ALL or CONSOLIDATED_BILLING)"
  type        = string
}

variable "organizational_units" {
  description = "List of organizational units to create within the AWS Organization"
  type        = list(string)
}

variable "tags" {
  description = "Tags to assign to each organizational unit"
  type        = map(string)
}
```

```hcl
# modules/custom_policies/main.tf
# Module to create custom policies and attach them to targets

resource "aws_organizations_policy" "custom_policy" {
  for_each = { for policy in var.policies : policy.name => policy }

  name     = each.value.name
  content  = each.value.content
  type     = "SERVICE_CONTROL_POLICY"
  tags     = {
    Purpose = each.value.purpose
  }
}

resource "aws_organizations_policy_attachment" "policy_attachment" {
  for_each = { for policy in var.policies : policy.name => policy }

  policy_id = aws_organizations_policy.custom_policy[each.key].id
  target_id = each.value.target
}
```

```hcl
# modules/custom_policies/variables.tf
# Variables for the Custom Policies module

variable "create_custom_policies" {
  description = "Whether to create custom policies for the organization"
  type        = bool
}

variable "policies" {
  description = "List of custom policies to create, including name, purpose, content, and attachment targets"
  type = list(object({
    name    = string
    purpose = string
    content = string
    target  = string
  }))
}
```

### Instructions to Apply:
1. Save the main script in `main.tf` and the modules in their respective directories.
2. Initialize Terraform: `terraform init`.
3. Review the plan: `terraform plan`.
4. Apply the configuration: `terraform apply`.
5. Confirm the changes when prompted.

### Assumptions:
- The AWS Organization is being created from scratch.
- Default values are provided for features, policy types, and organizational units.
- Custom policies are optional and can be added as needed.