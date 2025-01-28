resource "aws_cloudtrail" "landing_zone_trail" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  tags = var.default_tags
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = var.cloudtrail_s3_bucket_name

  # Enable versioning for log integrity
  versioning {
    enabled = true
  }

resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }