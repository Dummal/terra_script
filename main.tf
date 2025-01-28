resource "aws_s3_bucket" "aft_logs" {
  bucket = var.s3_bucket_name

  # Enable versioning
  versioning {
    enabled = true
  }

resource "aws_s3_bucket_policy" "aft_logs_policy" {
  bucket = aws_s3_bucket.aft_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyUnencryptedUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.aft_logs.arn}

resource "aws_kms_key" "aft_logs_kms_key" {
  description             = "KMS key for encrypting AFT logs and other resources"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1",
    Statement = [
      {
        Sid       = "AllowRootAccountAccess",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}