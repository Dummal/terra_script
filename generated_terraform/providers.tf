provider is used.
2. The parent ID of the organization is `r-1p5x`.
3. Email addresses for the accounts are provided.
4. Tags are added for better resource management.
5. Sensitive data (e.g., account emails) is managed using variables.

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

### Root Module: `main.tf`
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

provider "aws" {
  region = "us-east-1" # Default region
}