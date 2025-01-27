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
  description = "The feature set for the AWS Organization (e.g., ALL or CONSOLIDATED_BILLING)."
  type        = string
  default     = "ALL" # Default to enabling all features.
}

variable "policy_types" {
  description = "List of policy types to enable in the organization (e.g., SERVICE_CONTROL_POLICY, TAG_POLICY)."
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY"]
}

variable "organizational_units" {
  description = "List of organizational units to create within the AWS Organization."
  type        = list(string)
  default     = ["Security", "AuditLog"]
}

variable "tags" {
  description = "Tags to assign to each organizational unit."
  type        = map(string)
  default     = {
    Environment = "Production"
    Purpose     = "AWS Organization Setup"
  }
}
```

```hcl
# modules/aws_organization/main.tf
# Module to create AWS Organization and associated resources.

resource "aws_organizations_organization" "this" {
  feature_set = var.organization_features
}

resource "aws_organizations_policy_type" "this" {
  for_each = toset(var.policy_types)

  policy_type = each.value
  root_id     = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "this" {
  for_each = toset(var.organizational_units)

  name = each.value
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = var.tags
}

# Outputs
output "organization_id" {
  value = aws_organizations_organization.this.id
}

output "organizational_units" {
  value = aws_organizations_organizational_unit.this.*.id
}
```

```hcl
# modules/aws_organization/variables.tf
# Variables for the AWS Organization module.

variable "organization_features" {
  description = "The feature set for the AWS Organization (e.g., ALL or CONSOLIDATED_BILLING)."
  type        = string
}

variable "policy_types" {
  description = "List of policy types to enable in the organization."
  type        = list(string)
}

variable "organizational_units" {
  description = "List of organizational units to create within the AWS Organization."
  type        = list(string)
}

variable "tags" {
  description = "Tags to assign to each organizational unit."
  type        = map(string)
}
```

```hcl
# modules/aws_organization/outputs.tf
# Outputs for the AWS Organization module.

output "organization_id" {
  value       = aws_organizations_organization.this.id
  description = "The ID of the AWS Organization."
}

output "organizational_units" {
  value       = aws_organizations_organizational_unit.this.*.id
  description = "List of created Organizational Units."
}
```

### Instructions to Apply:
1. Save the main script in a file named `main.tf`.
2. Save the module files in a directory structure like:
   ```
   .
   ├── main.tf
   ├── variables.tf
   ├── modules
       └── aws_organization
           ├── main.tf
           ├── variables.tf
           ├── outputs.tf
   ```
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- The AWS Organization will use "ALL" features by default.
- Default policy types include "SERVICE_CONTROL_POLICY".
- Default organizational units are "Security" and "AuditLog".
- Tags are provided as key-value pairs for all organizational units.