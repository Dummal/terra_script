output "s3_bucket_name" {
  description = "The name of the S3 bucket for logs"
  value       = aws_s3_bucket.aft_logs.id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = aws_kms_key.aft_logs_kms_key.arn
}