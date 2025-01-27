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
# modules/aws_organization/main.tf
# Module to manage AWS Organization and related resources.

resource "aws_organizations_organization" "this" {
  feature_set = var.organization_features

  enabled_policy_types = var.policy_types

  tags = var.tags
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each = toset(var.organizational_units)

  name = each.value

  parent_id = aws_organizations_organization.this.id

  tags = var.tags
}

output "organization_id" {
  value = aws_organizations_organization.this.id
}

output "organizational_units" {
  value = aws_organizations_organizational_unit.ou[*].name
}
```

```hcl
# variables.tf
# Define input variables for the AWS Organization setup.

variable "aws_region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "us-east-1"
}

variable "organization_features" {
  description = "The feature set for the AWS Organization. Options: ALL or CONSOLIDATED_BILLING."
  type        = string
  default     = "ALL"
}

variable "policy_types" {
  description = "List of policy types to enable in the organization."
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY"]
}

variable "organizational_units" {
  description = "List of Organizational Units to create within the AWS Organization."
  type        = list(string)
  default     = ["Security", "Audit", "Development"]
}

variable "tags" {
  description = "Tags to assign to the AWS Organization and Organizational Units."
  type        = map(string)
  default     = {
    Environment = "Production"
    Purpose     = "AWS Organization Setup"
  }
}
```

```hcl
# outputs.tf
# Define outputs for the AWS Organization setup.

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
1. Save the above scripts in appropriate files:
   - `main.tf`
   - `modules/aws_organization/main.tf`
   - `variables.tf`
   - `outputs.tf`
2. Initialize Terraform: `terraform init`.
3. Review the plan: `terraform plan`.
4. Apply the configuration: `terraform apply`.
5. Confirm the changes when prompted.

### Assumptions:
- The AWS Organization will use "ALL" features by default.
- Default policy type is `SERVICE_CONTROL_POLICY`.
- Default Organizational Units are `Security`, `Audit`, and `Development`.
- Tags are provided for better resource management.
- Control Tower setup is not included as it requires manual intervention.