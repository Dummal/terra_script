variable "aft_lambda_execution_role_name" {
  description = "The name of the IAM role for AFT Lambda functions to execute."
  type        = string
}

variable "aft_lambda_execution_role_policy_arns" {
  description = "The list of policy ARNs to attach to the AFT Lambda execution role."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

variable "aft_account_provisioning_role_name" {
  description = "The name of the IAM role for AFT account provisioning operations."
  type        = string
}

variable "aft_account_provisioning_role_policy_name" {
  description = "The name of the custom policy for AFT account provisioning."
  type        = string
  default     = "aft-account-provisioning-policy"
}

variable "aft_account_provisioning_role_policy_document" {
  description = "The policy document for the AFT account provisioning role."
  type        = string
}

variable "aft_admin_role_name" {
  description = "The name of the IAM Admin role for managing AFT."
  type        = string
}

variable "aft_admin_role_policy_arns" {
  description = "The list of policy ARNs to attach to the AFT admin role."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

variable "aft_admin_role_mfa_required" {
  description = "Indicates whether MFA is required for the AFT admin role."
  type        = bool
  default     = true
}

variable "aft_admin_role_trusted_account_id" {
  description = "The account ID of the root user allowed to assume the AFT admin role."
  type        = string
}

variable "iam_resource_tags" {
  description = "Tags to attach to all IAM resources for identification."
  type        = map(string)
  default     = {
    Purpose   = "AFT"
    ManagedBy = "Terraform"
  }
}

variable "master_account_id" {
  description = "The master account ID for assigning permissions."
  type        = string
}