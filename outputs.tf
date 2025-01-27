output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.this.id
}

output "organization_root_id" {
  description = "The ID of the root of the AWS Organization"
  value       = aws_organizations_organization.this.roots[0].id
}

output "security_ou_id" {
  description = "The ID of the Security organizational unit"
  value       = aws_organizations_organizational_unit.security.id
}

output "audit_log_ou_id" {
  description = "The ID of the Audit Log organizational unit"
  value       = aws_organizations_organizational_unit.audit_log.id
}
