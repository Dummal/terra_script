resource "aws_organizations_organization" "this" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "sso.amazonaws.com",
    "controltower.amazonaws.com",
  ]

  feature_set = "ALL"

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = {
    Environment = "Production"
    Purpose     = "Security"
  }
}

resource "aws_organizations_organizational_unit" "audit_log" {
  name      = "Audit Log"
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = {
    Environment = "Production"
    Purpose     = "Audit"
  }
}

resource "aws_organizations_policy" "deny_root_user" {
  name = "DenyRootUser"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn": [
              "arn:aws:iam::*:root"
            ]
          }
        }
      }
    ]
  })

  depends_on = [aws_organizations_organization.this]
}

resource "aws_organizations_policy_attachment" "deny_root_user" {
  policy_id = aws_organizations_policy.deny_root_user.id
  target_id = aws_organizations_organization.this.roots[0].id

  depends_on = [aws_organizations_policy.deny_root_user]
}

# Note: Control Tower setup is not directly managed by Terraform.
# You'll need to enable Control Tower manually in the AWS Console after this Terraform apply.

    