resource "aws_cloudtrail" "default" {
  count                  = var.enable_cloudtrail ? 1 : 0
  name                   = "default-region-cloudtrail"
  s3_bucket_name         = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail  = true
  enable_log_file_validation = true
  cloud_watch_logs_role_arn   = aws_iam_role.cloudtrail_role.arn
  cloud_watch_logs_group_arn  = aws_cloudwatch_log_group.cloudtrail_log_group.arn
  tags = {
    Environment = "LandingZone"
    Owner       = var.landing_zone_username
  }

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "cloudtrail-logs-${var.landing_zone_username}

resource "aws_iam_role" "cloudtrail_role" {
  name = "cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name = "/aws/cloudtrail/default-region"

  tags = {
    Environment = "LandingZone"
    Owner       = var.landing_zone_username
  }