output "cloudtrail_bucket_name" {
  description = "The name of the S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_bucket.id
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail_log_group.name
}

output "cloudtrail_role_arn" {
  description = "The ARN of the IAM Role for CloudTrail."
  value       = aws_iam_role.cloudtrail_role.arn
}