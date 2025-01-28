output "organization_id" {
  value       = module.control_tower.organization_id
  description = "The ID of the AWS Organization."
}

output "organization_root_id" {
  value       = module.control_tower.organization_root_id
  description = "The root ID of the AWS Organization."
}

output "security_ou_id" {
  value       = module.control_tower.security_ou_id
  description = "The ID of the Security Organizational Unit."
}

output "audit_log_ou_id" {
  value       = module.control_tower.audit_log_ou_id
  description = "The ID of the Audit Log Organizational Unit."
}

output "aft_execution_role_arn" {
  value       = module.iam.aft_execution_role_arn
  description = "The ARN of the AFT execution role."
}

output "aft_account_provisioning_role_arn" {
  value       = module.iam.aft_account_provisioning_role_arn
  description = "The ARN of the AFT account provisioning role."
}

output "aft_admin_role_arn" {
  value       = module.iam.aft_admin_role_arn
  description = "The ARN of the AFT admin role."
}

output "s3_bucket_id" {
  value       = module.aws_resources.s3_bucket_id
  description = "The ID of the S3 bucket for AFT logs."
}

output "kms_key_arn" {
  value       = module.aws_resources.kms_key_arn
  description = "The ARN of the KMS key used for encryption."
}

output "sns_topic_arn" {
  value       = module.aws_resources.sns_topic_arn
  description = "The ARN of the SNS topic for notifications."
}

output "dynamodb_table_name" {
  value       = module.aws_resources.dynamodb_table_name
  description = "The name of the DynamoDB table for AFT requests."
}

output "organization_id" {
  value       = module.control_tower.organization_id
  description = "The ID of the AWS Organization."
}

output "organization_root_id" {
  value       = module.control_tower.organization_root_id
  description = "The root ID of the AWS Organization."
}

output "security_ou_id" {
  value       = module.control_tower.security_ou_id
  description = "The ID of the Security Organizational Unit."
}

output "audit_log_ou_id" {
  value       = module.control_tower.audit_log_ou_id
  description = "The ID of the Audit Log Organizational Unit."
}

output "aft_execution_role_arn" {
  value       = module.iam.aft_execution_role_arn
  description = "The ARN of the AFT execution role."
}

output "aft_account_provisioning_role_arn" {
  value       = module.iam.aft_account_provisioning_role_arn
  description = "The ARN of the AFT account provisioning role."
}

output "aft_admin_role_arn" {
  value       = module.iam.aft_admin_role_arn
  description = "The ARN of the AFT admin role."
}

output "s3_bucket_id" {
  value       = module.aws_resources.s3_bucket_id
  description = "The ID of the S3 bucket for AFT logs."
}

output "kms_key_arn" {
  value       = module.aws_resources.kms_key_arn
  description = "The ARN of the KMS key used for encryption."
}

output "sns_topic_arn" {
  value       = module.aws_resources.sns_topic_arn
  description = "The ARN of the SNS topic for notifications."
}

output "dynamodb_table_name" {
  value       = module.aws_resources.dynamodb_table_name
  description = "The name of the DynamoDB table for AFT requests."
}