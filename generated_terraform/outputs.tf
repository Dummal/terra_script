output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.org.id
}

output "dev_account_id" {
  description = "The ID of the Development account"
  value       = module.dev_account.account_id
}

output "prod_account_id" {
  description = "The ID of the Production account"
  value       = module.prod_account.account_id
}

output "security_account_id" {
  description = "The ID of the Security account"
  value       = module.security_account.account_id
}

output "audit_account_id" {
  description = "The ID of the Audit account"
  value       = module.audit_account.account_id
}

output "account_id" {
  description = "The ID of the AWS account"
  value       = aws_organizations_account.account.id
}