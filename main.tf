```hcl
# main.tf
# This Terraform script sets up an AWS Organization with modular configurations.
# It includes support for enabling features, creating organizational units (OUs),
# attaching tags, and defining custom policies.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# Module: AWS Organization
module "aws_organization" {
  source = "./modules/aws_organization"

  organization_features = var.organization_features
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
  description = "List of created Organizational Units (OUs)."
}

output "custom_policies" {
  value       = module.custom_policies.policy_ids
  description = "List of custom policy IDs created."
}
```

```hcl
# variables.tf
# Define variables for the AWS Organization setup.

variable "aws_region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "us-east-1"
}

variable "organization_features" {
  description = "The features to enable for the AWS Organization (e.g., ALL or CONSOLIDATED_BILLING)."
  type        = string
  default     = "ALL"
}

variable "organizational_units" {
  description = "A list of organizational units (OUs) to create within the AWS Organization."
  type        = list(string)
  default     = ["Security", "Audit", "Development"]
}

variable "tags" {
  description = "Tags to assign to each organizational unit."
  type        = map(string)
  default     = {
    Environment = "Production"
    Purpose     = "AWS Organization Setup"
  }
}

variable "create_custom_policies" {
  description = "Whether to create custom policies for the organization."
  type        = bool
  default     = false
}

variable "policies" {
  description = "A list of custom policies to create, including their names, purposes, and JSON content."
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
# modules/aws_organization/main.tf
# Module to create and manage AWS Organization and Organizational Units.

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
  value = aws_organizations_organizational_unit.ou[*].id
}
```

```hcl
# modules/aws_organization/variables.tf
# Variables for the AWS Organization module.

variable "organization_features" {
  description = "The features to enable for the AWS Organization."
  type        = string
}

variable "organizational_units" {
  description = "A list of organizational units (OUs) to create."
  type        = list(string)
}

variable "tags" {
  description = "Tags to assign to each organizational unit."
  type        = map(string)
}
```

```hcl
# modules/custom_policies/main.tf
# Module to create and manage custom policies for the AWS Organization.

resource "aws_organizations_policy" "custom_policy" {
  count = var.create_custom_policies ? length(var.policies) : 0

  name        = var.policies[count.index].name
  description = var.policies[count.index].purpose
  content     = var.policies[count.index].content
  type        = "SERVICE_CONTROL_POLICY"

  attachment_target_id = var.policies[count.index].target
}

output "policy_ids" {
  value = aws_organizations_policy.custom_policy[*].id
}
```

```hcl
# modules/custom_policies/variables.tf
# Variables for the Custom Policies module.

variable "create_custom_policies" {
  description = "Whether to create custom policies for the organization."
  type        = bool
}

variable "policies" {
  description = "A list of custom policies to create, including their names, purposes, and JSON content."
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
- Default values are provided for organizational units and tags.
- Custom policies are optional and can be enabled by setting `create_custom_policies` to `true`.