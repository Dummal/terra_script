variable "default_region" {
  description = "The default AWS region for the landing zone."
  type        = string
  default     = "us-east-1"
}

variable "additional_regions" {
  description = "List of additional AWS regions for multi-region support."
  type        = list(string)
  default     = ["us-west-1", "us-west-2"]
}

variable "landing_zone_username" {
  description = "Username for the landing zone."
  type        = string
}

variable "landing_zone_email" {
  description = "Email address for the landing zone."
  type        = string
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail logging."
  type        = bool
  default     = true
}