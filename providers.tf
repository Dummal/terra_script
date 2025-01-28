provider "aws" {
  # Use variables for region and profile to support multi-region deployments
  region = var.aws_region
}