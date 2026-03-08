variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project name to use in resource naming"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to all resources (must include Environment and Terraform keys)"
  type        = map(string)
}

# -------------------------------
# External IaC VPC info
# -------------------------------
variable "vpc_state_bucket" {
  type        = string
  description = "S3 bucket for VPC state"
}

variable "vpc_state_key" {
  type        = string
  description = "S3 key for VPC state file"
}

variable "vpc_state_region" {
  type        = string
  description = "AWS region of the S3 bucket"
}