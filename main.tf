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
  name               = "aft-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Purpose    = "AFT"
    ManagedBy  = "Terraform"
  }

resource "aws_iam_role" "aft_account_provisioning_role" {
  name               = "aft-account-provisioning-role"
  assume_role_policy = data.aws_iam_policy_document.org_assume_role.json

  tags = {
    Purpose    = "AFT"
    ManagedBy  = "Terraform"
  }

resource "aws_iam_role" "aft_admin_role" {
  name               = "aft-admin-role"
  assume_role_policy = data.aws_iam_policy_document.admin_assume_role.json

  tags = {
    Purpose    = "AFT"
    ManagedBy  = "Terraform"
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

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }

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