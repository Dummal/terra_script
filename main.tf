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
    