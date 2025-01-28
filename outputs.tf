output "s3_bucket_name" {
  value       = aws_s3_bucket.log_bucket.bucket
  description = "The name of the S3 bucket for logs"
}

output "kms_key_arn" {
  value       = aws_kms_key.log_encryption_key.arn
  description = "The ARN of the KMS key used for encryption"
}