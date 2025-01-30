resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

resource "aws_organizations_account" "account" {
  name      = var.account_name
  email     = var.email
  parent_id = var.parent_id

  tags = var.tags
}