resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each = toset(var.organizational_units)

  name      = each.value
  parent_id = aws_organizations_organization.org.roots[0].id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }

resource "aws_iam_role" "aft_execution_role" {
  name = "aft-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }

resource "aws_iam_policy" "aft_execution_policy" {
  name        = "aft-execution-policy"
  description = "Policy for AFT Lambda execution role."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:*"
        Resource = "*"
      }

resource "aws_iam_role_policy_attachment" "aft_execution_attach" {
  role       = aws_iam_role.aft_execution_role.name
  policy_arn = aws_iam_policy.aft_execution_policy.arn
}

resource "aws_s3_bucket" "aft_logs" {
  bucket = var.aft_logs_bucket_name

  versioning {
    enabled = true
  }

resource "aws_kms_key" "aft_key" {
  description             = "KMS key for AFT resources"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.master_account_id}

resource "aws_sns_topic" "aft_notifications" {
  name = "aft-notifications"

  kms_master_key_id = aws_kms_key.aft_key.arn

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }

resource "aws_dynamodb_table" "aft_requests" {
  name           = "aft-requests"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  point_in_time_recovery {
    enabled = true
  }