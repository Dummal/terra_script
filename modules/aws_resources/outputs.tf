output "s3_bucket_id" {
  value       = aws_s3_bucket.aft_logs.id
  description = "The ID of the S3 bucket used for AFT logs."
}

output "kms_key_arn" {
  value       = aws_kms_key.aft_key.arn
  description = "The ARN of the KMS key used for encrypting resources."
}

output "sns_topic_arn" {
  value       = aws_sns_topic.aft_notifications.arn
  description = "The ARN of the SNS topic used for AFT notifications."
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.aft_requests.name
  description = "The name of the DynamoDB table used for handling AFT requests."
}

output "cloudwatch_log_group_name" {
  value       = aws_cloudwatch_log_group.aft_logs.name
  description = "The name of the CloudWatch Log Group used for AFT operations."
}