variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for storing AFT logs"
  type        = string
}

variable "common_tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "production"
    ManagedBy   = "terraform"
  }