resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_organizations_account" "accounts" {
  for_each = var.accounts

  name  = each.value.name
  email = each.value.email
  role_name = "OrganizationAccountAccessRole"

  tags = var.tags
}