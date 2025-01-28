resource "aws_cloudtrail" "main" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "landing-zone-cloudtrail"
  s3_bucket_name                = "landing-zone-cloudtrail-logs-${random_id.suffix.hex}

resource "random_id" "suffix" {
  byte_length = 4
}