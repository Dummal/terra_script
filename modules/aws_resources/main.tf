resource "aws_s3_bucket" "aft_logs" {
  bucket = "aft-logs-bucket"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.aft_key.arn
      }
    }
  }

  block_public_access {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Name        = "AFT Logs"
  }
}

resource "aws_kms_key" "aft_key" {
  description             = "KMS key for AFT resources"
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowRootAccountAccess"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudWatchLogsAccess"
        Effect    = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource  = "*"
      }
    ]
  })

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Name        = "AFT KMS Key"
  }
}

resource "aws_kms_alias" "aft_key_alias" {
  name          = "alias/aft-key"
  target_key_id = aws_kms_key.aft_key.id
}

resource "aws_sns_topic" "aft_notifications" {
  name              = "aft-notifications"
  kms_master_key_id = aws_kms_key.aft_key.arn

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Name        = "AFT Notifications"
  }
}

resource "aws_dynamodb_table" "aft_requests" {
  name           = "aft-requests"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.aft_key.arn
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Name        = "AFT Requests"
  }
}

resource "aws_cloudwatch_log_group" "aft_logs" {
  name              = "/aws/aft/logs"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.aft_key.arn

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Name        = "AFT Logs"
  }
}