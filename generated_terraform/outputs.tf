output "organization_id" {
  value = module.aws_organization.organization_id
}

output "account_ids" {
  value = module.aws_organization.account_ids
}

output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = module.aws_organization.organization_id
}

output "account_ids" {
  description = "The IDs of the created AWS accounts."
  value       = module.aws_organization.account_ids
}

output "organization_id" {
  value = aws_organizations_organization.this.id
}

output "account_ids" {
  value = { for k, v in aws_organizations_account.accounts : k => v.id }

output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = aws_organizations_organization.this.id
}

output "account_ids" {
  description = "The IDs of the created AWS accounts."
  value       = { for k, v in aws_organizations_account.accounts : k => v.id }