provider is used.
2. The parent ID (`r-1p5x`) is the root organizational unit (OU) ID.
3. Email addresses for the accounts are provided.
4. Tags are added for better resource management.
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

provider "aws" {
  region = "us-east-1" # Default region
}