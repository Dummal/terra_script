output "aft_execution_role_arn" {
  value       = aws_iam_role.aft_execution_role.arn
  description = "The ARN of the AFT execution role used by Lambda functions."
}

output "aft_admin_role_arn" {
  value       = aws_iam_role.aft_admin_role.arn
  description = "The ARN of the AFT admin role with AdministratorAccess permissions."
}

output "aft_account_provisioning_role_arn" {
  value       = aws_iam_role.aft_account_provisioning_role.arn
  description = "The ARN of the AFT account provisioning role for managing AWS Organizations accounts."
}