resource management.
5. Sensitive data (e.g., account emails) is passed via variables.

### Directory Structure:
```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── modules/
    └── aws_account/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
```

---

### Root `main.tf`
```hcl
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }

resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
}

resource "aws_organizations_account" "account" {
  name      = var.account_name
  email     = var.email
  parent_id = var.parent_id

  tags = var.tags
}