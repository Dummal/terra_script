resource "aws_s3_bucket" "aft_logs_bucket" {
  bucket = "aft-logs-bucket-863518414447"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.aft_kms_key.arn
      }
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
  }

  block_public_access {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

resource "aws_kms_key" "aft_kms_key" {
  description             = "KMS key for AFT resources"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Enable IAM User Permissions"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::863518414447:root"
        }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "Allow CloudWatch Logs"
        Effect    = "Allow"
        Principal = {
          Service = "logs.us-west-2.amazonaws.com"
        }
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic" "aft_notifications" {
  name              = "aft-notifications"
  kms_master_key_id = aws_kms_key.aft_kms_key.arn

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_dynamodb_table" "aft_requests" {
  name           = "aft-requests"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.aft_kms_key.arn
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "aft_logs" {
  name              = "/aws/aft/logs"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.aft_kms_key.arn

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}