output "s3_bucket_id" {
  value       = module.aws_resources.s3_bucket_id
  description = "The ID of the S3 bucket created for storing AFT logs."
}

output "kms_key_arn" {
  value       = module.aws_resources.kms_key_arn
  description = "The ARN of the KMS key used for encryption across AWS resources."
}

output "sns_topic_arn" {
  value       = module.aws_resources.sns_topic_arn
  description = "The ARN of the SNS topic created for AFT notifications."
}

output "dynamodb_table_name" {
  value       = module.aws_resources.dynamodb_table_name
  description = "The name of the DynamoDB table created for AFT requests."
}

output "cloudwatch_log_group_name" {
  value       = module.aws_resources.cloudwatch_log_group_name
  description = "The name of the CloudWatch Log Group created for AFT logging."
}