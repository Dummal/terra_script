output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = module.control_tower.organization_id
}

output "organization_root_id" {
  description = "The root ID of the AWS Organization"
  value       = module.control_tower.organization_root_id
}

output "security_ou_id" {
  description = "The ID of the Security Organizational Unit"
  value       = module.control_tower.security_ou_id
}

output "audit_log_ou_id" {
  description = "The ID of the Audit Log Organizational Unit"
  value       = module.control_tower.audit_log_ou_id
}

output "aft_execution_role_arn" {
  description = "The ARN of the AFT execution role"
  value       = module.iam.aft_execution_role_arn
}

output "aft_account_provisioning_role_arn" {
  description = "The ARN of the AFT account provisioning role"
  value       = module.iam.aft_account_provisioning_role_arn
}

output "aft_admin_role_arn" {
  description = "The ARN of the AFT admin role"
  value       = module.iam.aft_admin_role_arn
}

output "s3_bucket_id" {
  description = "The ID of the S3 bucket for AFT logs"
  value       = module.aws_resources.s3_bucket_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = module.aws_resources.kms_key_arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value       = module.aws_resources.sns_topic_arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = module.aws_resources.dynamodb_table_name
}

output "organization_id" {
  value = aws_organizations_organization.org.id
}

output "organization_root_id" {
  value = aws_organizations_organization.org.roots[0].id
}

output "security_ou_id" {
  value = aws_organizations_organizational_unit.ou["Security"].id
}

output "audit_log_ou_id" {
  value = aws_organizations_organizational_unit.ou["Audit Log"].id
}

output "aft_execution_role_arn" {
  value = aws_iam_role.aft_execution_role.arn
}

output "s3_bucket_id" {
  value = aws_s3_bucket.aft_logs.id
}

output "kms_key_arn" {
  value = aws_kms_key.aft_key.arn
}