```hcl
# main.tf
# This Terraform script sets up an AWS infrastructure with reusable modules and best practices.

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }

  backend "s3" {
    bucket         = "your-terraform-state-bucket" # Replace with your S3 bucket name
    key            = "terraform/state/main.tfstate"
    region         = "us-east-1"                  # Replace with your region
    encrypt        = true
    dynamodb_table = "terraform-lock-table"       # Replace with your DynamoDB table for state locking
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" # Replace with your preferred region
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "ExampleProject"
    Environment = "dev"
  }
}

# Module: VPC
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block = "10.0.0.0/16"
  environment    = var.environment
  tags           = var.tags
}

# Module: EC2
module "ec2" {
  source = "./modules/ec2"

  instance_type = "t2.micro"
  ami_id        = "ami-0c55b159cbfafe1f0" # Replace with a valid AMI ID for your region
  key_name      = "your-key-pair"         # Replace with your key pair name
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[0]
  environment   = var.environment
  tags          = var.tags
}

# Outputs
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "ec2_instance_id" {
  description = "The ID of the created EC2 instance"
  value       = module.ec2.instance_id
}
```

### Module: VPC (`modules/vpc/main.tf`)
```hcl
# VPC Module

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name = "${var.environment}-vpc"
  })
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  tags = merge(var.tags, {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  })
}

data "aws_availability_zones" "available" {}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
```

### Module: EC2 (`modules/ec2/main.tf`)
```hcl
# EC2 Module

resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id

  tags = merge(var.tags, {
    Name = "${var.environment}-ec2-instance"
  })
}

output "instance_id" {
  value = aws_instance.main.id
}
```

### Variables for Modules (`modules/vpc/variables.tf`)
```hcl
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
}
```

### Variables for EC2 Module (`modules/ec2/variables.tf`)
```hcl
variable "instance_type" {
  description = "The type of instance to create"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
}

variable "key_name" {
  description = "The key pair name to use for the instance"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to launch the instance in"
  type        = string
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
}
```

### Instructions to Apply
1. Save the main script in `main.tf`.
2. Create the `modules/vpc` and `modules/ec2` directories and save the respective module files.
3. Initialize Terraform: `terraform init`.
4. Review the plan: `terraform plan`.
5. Apply the configuration: `terraform apply`.
6. Confirm the changes when prompted.