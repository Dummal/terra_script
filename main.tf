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
module "organization_policies" {
  source = "./modules/organization_policies"

  policies = var.policies
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

variable "organizational_units" {
  description = "List of organizational units to create"
  type        = list(string)
  default     = ["Security", "AuditLog"]
}

variable "tags" {
  description = "Tags to assign to organizational units"
  type        = map(string)
  default     = {
    Environment = "Production"
    Purpose     = "Security"
  }
}

variable "services" {
  description = "List of AWS services to grant access to the organization"
  type        = list(string)
  default     = ["cloudtrail.amazonaws.com", "config.amazonaws.com"]
}

variable "policies" {
  description = "List of custom policies to create and their details"
  type = list(object({
    name        = string
    description = string
    content     = string
    target_id   = string
  }))
  default = []
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

output "policies" {
  description = "List of created policies"
  value       = module.organization_policies.policies
}
```

### Module: `aws_organization`
```hcl
# modules/aws_organization/main.tf
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

### Module: `service_access`
```hcl
# modules/service_access/main.tf
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_organizations_organization_service_access" "service_access" {
  for_each = toset(var.services)

  service_principal = each.value
}
```

### Module: `organization_policies`
```hcl
# modules/organization_policies/main.tf
resource "aws_organizations_policy" "policy" {
  for_each = { for policy in var.policies : policy.name => policy }

  name        = each.value.name
  description = each.value.description
  content     = each.value.content
  type        = "SERVICE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "policy_attachment" {
  for_each = { for policy in var.policies : policy.name => policy }

  policy_id = aws_organizations_policy.policy[each.key].id
  target_id = each.value.target_id
}

output "policies" {
  value = aws_organizations_policy.policy[*].name
}
```

### Instructions to Apply
1. Save the main script in `main.tf` and the modules in their respective directories (`modules/aws_organization`, `modules/service_access`, `modules/organization_policies`).
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the plan:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```
5. Confirm the changes when prompted.

### Assumptions
- The AWS Organization is being created from scratch.
- Default features are set to `ALL`.
- No custom policies are defined unless explicitly provided.
- Control Tower setup is manual and not included in this script.