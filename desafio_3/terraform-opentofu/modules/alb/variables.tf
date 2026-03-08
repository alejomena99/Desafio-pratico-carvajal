variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to resources (must include Environment and Terraform keys)"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID for ALB"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "alb_port" {
  description = "Port for ALB listener and target group"
  type        = number
  default     = 80
}

variable "target_path" {
  description = "Health check path for target group"
  type        = string
  default     = "/"
}

variable "module_name" {
  description = "Name of the module/service (used for unique naming)"
  type        = string
}