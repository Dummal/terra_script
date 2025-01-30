output "organization_id" {
  value       = aws_organizations_organization.this.id
  description = "The unique identifier (ID) of the AWS Organization."
}

output "organization_root_id" {
  value       = aws_organizations_organization.this.roots[0].id
  description = "The unique identifier (ID) of the root in the AWS Organization."
}

output "security_ou_id" {
  value       = aws_organizations_organizational_unit.security.id
  description = "The unique identifier (ID) of the Security Organizational Unit (OU)."
}

output "audit_log_ou_id" {
  value       = aws_organizations_organizational_unit.audit_log.id
  description = "The unique identifier (ID) of the Audit Log Organizational Unit (OU)."
}