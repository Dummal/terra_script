```hcl
# main.tf
# This Terraform script sets up an AWS Organization with modular configurations.
# It includes support for enabling features, creating organizational units (OUs),
# attaching tags, and defining custom policies.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
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
    Purpose     = "AWS Organization Management"
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
  value = aws_organizations_organizational_unit.ou[*].name
}
```

```hcl
# modules/custom_policies/main.tf
# Module to create and attach custom policies to the AWS Organization.

resource "aws_organizations_policy" "custom_policy" {
  count = var.create_custom_policies ? length(var.policies) : 0

  name        = var.policies[count.index].name
  description = var.policies[count.index].purpose
  content     = var.policies[count.index].content
  type        = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "policy_attachment" {
  count = var.create_custom_policies ? length(var.policies) : 0

  policy_id = aws_organizations_policy.custom_policy[count.index].id
  target_id = var.policies[count.index].target
}
```

```hcl
# outputs.tf
# Outputs for the AWS Organization setup.

output "organization_id" {
  value       = module.aws_organization.organization_id
  description = "The ID of the AWS Organization."
}

output "organizational_units" {
  value       = module.aws_organization.organizational_units
  description = "List of created Organizational Units (OUs)."
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
- Default features are set to "ALL".
- Organizational Units and tags are customizable via variables.
- Custom policies are optional and can be defined in JSON format.