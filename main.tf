resource "aws_kms_key" "log_encryption_key" {
  description             = "KMS key for encrypting S3 bucket, DynamoDB, SNS, and CloudWatch logs"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [
    {
      "Sid": "AllowRootAccountAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}

resource "aws_s3_bucket" "log_bucket" {
  bucket = var.s3_bucket_name

  # Enable versioning
  versioning {
    enabled = true
  }