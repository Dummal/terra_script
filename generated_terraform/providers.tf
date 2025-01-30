provider is used.

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
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

provider "aws" {
  region = "us-east-1" # Default region, can be overridden
}