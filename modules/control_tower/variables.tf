variable "enable_aws_organizations" {
  type    = bool
  default = true
}

variable "aws_services_to_integrate" {
  type    = list(string)
  default = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "sso.amazonaws.com",
    "controltower.amazonaws.com"
  ]
}

variable "aws_organizations_feature_set" {
  type    = string
  default = "ALL"
}

variable "enabled_policy_types" {
  type    = list(string)
  default = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
}

variable "organizational_units" {
  type = list(object({
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
      name = "Audit Log"
      tags = {
        Environment = "Production"
        Purpose     = "Audit"
      }
    }
  ]
}

variable "create_service_control_policy" {
  type    = bool
  default = true
}

variable "scp_name" {
  type    = string
  default = "DenyRootUser"
}

variable "scp_policy_document" {
  type = object({
    Version   = string
    Statement = list(object({
      Effect    = string
      Action    = list(string)
      Resource  = list(string)
      Principal = object({
        AWS = string
      })
    }))
  })
  default = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Action    = ["*"]
        Resource  = ["*"]
        Principal = {
          AWS = "arn:aws:iam::*:root"
        }
      }
    ]
  }
}

variable "scp_attachment_target" {
  type    = string
  default = "root"
}

variable "enable_control_tower" {
  type    = bool
  default = true
}

variable "master_account_email" {
  type = string
}

variable "control_tower_region" {
  type = string
}

variable "output_organization_ids" {
  type    = bool
  default = true
}