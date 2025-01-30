resource "aws_iam_role" "aft_lambda_execution_role" {
  name = "aft-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Purpose   = "AFT"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "aft_lambda_execution_policy_attachment" {
  role       = aws_iam_role.aft_lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "aft_account_provisioning_role" {
  name = "aft-account-provisioning-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "organizations.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Purpose   = "AFT"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_policy" "aft_account_provisioning_policy" {
  name        = "aft-account-provisioning-policy"
  description = "Policy for managing accounts in AWS Organizations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "organizations:CreateAccount",
          "organizations:ListAccounts",
          "organizations:MoveAccount",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Purpose   = "AFT"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "aft_account_provisioning_policy_attachment" {
  role       = aws_iam_role.aft_account_provisioning_role.name
  policy_arn = aws_iam_policy.aft_account_provisioning_policy.arn
}

resource "aws_iam_role" "aft_admin_role" {
  name = "aft-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.master_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })

  tags = {
    Purpose   = "AFT"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "aft_admin_policy_attachment" {
  role       = aws_iam_role.aft_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}