Based on the details provided in the Terraform script, here is the exact `provider.tf` file:

```hcl
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "master"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.master_account_id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "security"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.security_account_id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "audit"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.audit_account_id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "dev"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.dev_account_id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias  = "prod"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.prod_account_id}:role/OrganizationAccountAccessRole"
  }
}
```

### Explanation:
1. **Default AWS Provider**: The default provider is configured with the `aws_region` variable.
2. **Aliased Providers**: Additional providers are configured with aliases (`master`, `security`, `audit`, `dev`, `prod`) to assume roles in different AWS accounts. Each assumes the `OrganizationAccountAccessRole` in the respective account.
3. **Variables Used**:
   - `var.aws_region`: Specifies the AWS region.
   - `var.master_account_id`, `var.security_account_id`, `var.audit_account_id`, `var.dev_account_id`, `var.prod_account_id`: These variables hold the account IDs for the respective accounts.

This `provider.tf` ensures that Terraform can manage resources across multiple AWS accounts by assuming the appropriate roles.