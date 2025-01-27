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
  source = "./modules/aws_organization"

  organization_features = var.organization_features
  organizational_units  = var.organizational_units
  tags                  = var.tags
}

# Module: Service Access
module "service_access" {
  source = "./modules/service_access"

  services = var.services
}

# Module: Policies
module "policies" {
  source = "./modules/policies"

  custom_policies = var.custom_policies
}

# Outputs
output "organization_id" {
  value       = module.aws_organization.organization_id
  description = "The ID of the AWS Organization."
}

output "organizational_units" {
  value       = module.aws_organization.organizational_units
  description = "The list of created Organizational Units."
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
  description = "A list of organizational units to create within the AWS Organization."
  type        = list(string)
  default     = ["Security", "AuditLog"]
}

variable "tags" {
  description = "Tags to assign to each organizational unit."
  type        = map(string)
  default     = {
    Environment = "Production"
    Purpose     = "Security"
  }
}

variable "services" {
  description = "A list of AWS services to grant access to the organization."
  type        = list(string)
  default     = ["cloudtrail.amazonaws.com", "config.amazonaws.com"]
}

variable "custom_policies" {
  description = "A list of custom policies to create and their details."
  type = list(object({
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
# Module to create an AWS Organization and Organizational Units.

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
# modules/service_access/main.tf
# Module to enable service access for AWS Organization.

resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_organizations_organization_service_access" "service_access" {
  for_each = toset(var.services)

  service_principal = each.value
}
```

```hcl
# modules/policies/main.tf
# Module to create and attach custom policies.

resource "aws_organizations_policy" "custom_policy" {
  for_each = { for policy in var.custom_policies : policy.name => policy }

  name        = each.value.name
  description = each.value.description
  content     = each.value.content
  type        = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "policy_attachment" {
  for_each = { for policy in var.custom_policies : policy.name => policy }

  policy_id = aws_organizations_policy.custom_policy[each.key].id
  target_id = each.value.target_id
}
```

### Instructions to Apply:
1. Save the main script in `main.tf` and the modules in their respective directories (`modules/aws_organization`, `modules/service_access`, `modules/policies`).
2. Initialize Terraform: `terraform init`.
3. Review the plan: `terraform plan`.
4. Apply the configuration: `terraform apply`.
5. Confirm the changes when prompted.

### Assumptions:
- The AWS Organization is being created from scratch.
- Default values are provided for features, OUs, and tags.
- Custom policies are optional and can be defined as needed.
- Control Tower setup is not included, as it requires manual intervention.