output "cloudtrail_status" {
  description = "Status of CloudTrail setup"
  value       = module.cloudtrail.status
}

output "status" {
  description = "CloudTrail setup status"
  value       = var.enable_cloudtrail ? "Enabled" : "Disabled"
}