```hcl
# main.tf
# This Terraform script creates an AWS Organizational Unit (OU) with optional Service Control Policies (SCPs).
# It is modular, reusable, and adheres to best practices.

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

# Module to create an Organizational Unit (OU)
module "organizational_unit" {
  source = "./modules/organizational_unit"

  parent_id = var.parent_id
  name      = var.ou_name
  tags      = var.tags
}

# Module to apply Service Control Policies (SCPs) to the OU
module "service_control_policies" {
  source = "./modules/service_control_policies"

  ou_id   = module.organizational_unit.ou_id
  scp_ids = var.scp_ids
}

# Variables
variable "aws_region" {
  description = "The AWS region to use for the provider."
  type        = string
  default     = "us-east-1"
}

variable "parent_id" {
  description = "The ID of the parent organizational unit or root."
  type        = string
}

variable "ou_name" {
  description = "The name of the organizational unit to create."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the organizational unit."
  type        = map(string)
  default     = {}
}

variable "scp_ids" {
  description = "List of Service Control Policy (SCP) IDs to attach to the organizational unit."
  type        = list(string)
  default     = []
}

# Outputs
output "organizational_unit_id" {
  description = "The ID of the created organizational unit."
  value       = module.organizational_unit.ou_id
}

output "attached_scp_ids" {
  description = "The list of SCP IDs attached to the organizational unit."
  value       = module.service_control_policies.attached_scp_ids
}
```

```hcl
# modules/organizational_unit/main.tf
# Module to create an AWS Organizational Unit (OU)

resource "aws_organizations_organizational_unit" "this" {
  parent_id = var.parent_id
  name      = var.name
  tags      = var.tags
}

# Outputs
output "ou_id" {
  description = "The ID of the created organizational unit."
  value       = aws_organizations_organizational_unit.this.id
}
```

```hcl
# modules/organizational_unit/variables.tf
variable "parent_id" {
  description = "The ID of the parent organizational unit or root."
  type        = string
}

variable "name" {
  description = "The name of the organizational unit to create."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the organizational unit."
  type        = map(string)
  default     = {}
}
```

```hcl
# modules/service_control_policies/main.tf
# Module to attach Service Control Policies (SCPs) to an Organizational Unit (OU)

resource "aws_organizations_policy_attachment" "this" {
  for_each = toset(var.scp_ids)

  policy_id = each.value
  target_id = var.ou_id
}

# Outputs
output "attached_scp_ids" {
  description = "The list of SCP IDs attached to the organizational unit."
  value       = var.scp_ids
}
```

```hcl
# modules/service_control_policies/variables.tf
variable "ou_id" {
  description = "The ID of the organizational unit to attach SCPs to."
  type        = string
}

variable "scp_ids" {
  description = "List of Service Control Policy (SCP) IDs to attach to the organizational unit."
  type        = list(string)
  default     = []
}
```

### Instructions to Apply:
1. Save the main script in a file named `main.tf`.
2. Save the module files in their respective directories (`modules/organizational_unit` and `modules/service_control_policies`).
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.

### Assumptions:
- The `parent_id` is provided and valid (e.g., the root or another OU ID).
- SCP IDs are optional; if none are provided, no SCPs will be attached.
- Tags are optional and can be customized as needed.