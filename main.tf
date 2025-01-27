```hcl
# main.tf
# Terraform script to create an AWS Organization with modular design and reusable configurations.

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

# Module to create AWS Organization
module "aws_organization" {
  source = "./modules/aws_organization"

  organization_features = var.organization_features
  policy_types          = var.policy_types
  organizational_units  = var.organizational_units
  tags                  = var.tags
}

# Variables
variable "aws_region" {
  description = "AWS region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

variable "organization_features" {
  description = "Features to enable for the AWS Organization (e.g., ALL or CONSOLIDATED_BILLING)"
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
  description = "Global tags to apply to all resources"
  type        = map(string)
  default     = {
    Project     = "AWS Organization Setup"
    Environment = "Production"
  }
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = module.aws_organization.organization_id
}

output "organizational_units" {
  description = "List of created organizational units"
  value       = module.aws_organization.organizational_units
}
```

```hcl
# modules/aws_organization/main.tf
# Module to create AWS Organization and associated resources.

resource "aws_organizations_organization" "this" {
  feature_set = var.organization_features

  enabled_policy_types = var.policy_types
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each = { for ou in var.organizational_units : ou.name => ou }

  name      = each.value.name
  parent_id = aws_organizations_organization.this.id
  tags      = merge(var.tags, each.value.tags)
}

# Outputs
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.this.id
}

output "organizational_units" {
  description = "List of created organizational units"
  value = [
    for ou in aws_organizations_organizational_unit.ou :
    {
      name = ou.name
      id   = ou.id
    }
  ]
}
```

```hcl
# modules/aws_organization/variables.tf
# Variables for the AWS Organization module.

variable "organization_features" {
  description = "Features to enable for the AWS Organization (e.g., ALL or CONSOLIDATED_BILLING)"
  type        = string
}

variable "policy_types" {
  description = "List of policy types to enable in the organization (e.g., SERVICE_CONTROL_POLICY, TAG_POLICY)"
  type        = list(string)
}

variable "organizational_units" {
  description = "List of organizational units to create within the AWS Organization"
  type        = list(object({
    name = string
    tags = map(string)
  }))
}

variable "tags" {
  description = "Global tags to apply to all resources"
  type        = map(string)
}
```

### Instructions to Apply:
1. Save the main script in `main.tf` and the module in `modules/aws_organization/`.
2. Initialize Terraform: `terraform init`.
3. Review the plan: `terraform plan`.
4. Apply the configuration: `terraform apply`.
5. Confirm the changes when prompted.

### Assumptions:
- The AWS Organization is being created from scratch.
- Default features are set to `ALL`.
- Organizational units and tags are customizable via variables.
- Policies and OUs are created only if specified in the variables.