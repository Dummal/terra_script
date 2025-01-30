Below is the `outputs.tf` file generated based on the provided Terraform script and the details shared:

```hcl
output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = aws_organizations_organization.org.id
}

output "root_id" {
  description = "The root ID of the AWS Organization."
  value       = aws_organizations_organization.org.roots[0].id
}

output "security_ou_id" {
  description = "The ID of the Security Organizational Unit (OU)."
  value       = module.control_tower.security_ou_id
}

output "audit_log_ou_id" {
  description = "The ID of the Audit Log Organizational Unit (OU)."
  value       = module.control_tower.audit_log_ou_id
}

output "sandbox_ou_id" {
  description = "The ID of the Sandbox Organizational Unit (OU)."
  value       = module.control_tower.sandbox_ou_id
}

output "s3_bucket_id" {
  description = "The ID of the S3 bucket created for AFT logs."
  value       = module.aws_resources.s3_bucket_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption."
  value       = module.aws_resources.kms_key_arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic created for notifications."
  value       = module.aws_resources.sns_topic_arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table created for AFT requests."
  value       = module.aws_resources.dynamodb_table_name
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group created for AFT logs."
  value       = module.aws_resources.cloudwatch_log_group_name
}

output "dev_account_id" {
  description = "The account ID of the Dev account."
  value       = module.control_tower.dev_account_id
}

output "prod_account_id" {
  description = "The account ID of the Prod account."
  value       = module.control_tower.prod_account_id
}

output "shared_account_id" {
  description = "The account ID of the Shared account."
  value       = module.control_tower.shared_account_id
}

output "aft_execution_role_arn" {
  description = "The ARN of the AFT execution IAM role."
  value       = module.iam.aft_execution_role_arn
}

output "aft_account_provisioning_role_arn" {
  description = "The ARN of the AFT account provisioning IAM role."
  value       = module.iam.aft_account_provisioning_role_arn
}

output "aft_admin_role_arn" {
  description = "The ARN of the AFT admin IAM role."
  value       = module.iam.aft_admin_role_arn
}
```

This `outputs.tf` file defines all the outputs for the resources and modules mentioned in the Terraform script. Each output includes a description and references the appropriate resource or module attribute.