variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to resources (must include Environment and Terraform keys)"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID for ECS"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS service"
  type        = list(string)
}

variable "alb_tg_arn" {
  description = "Target Group ARN for Fargate service"
  type        = string
}

variable "alb_sg_id" {
  description = "Security Group ID of the ALB"
  type        = string
}

variable "container_image" {
  description = "Container image for ECS Task"
  type        = string
}

variable "container_name" {
  description = "Container name for ECS Task"
  type        = string
  default     = "app"
}

variable "container_port" {
  description = "Container port for ECS Task"
  type        = number
  default     = 80
}

variable "cpu" {
  description = "CPU units for ECS Task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory for ECS Task"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired ECS service count"
  type        = number
  default     = 1
}

variable "environment_variables" {
  description = "Map of environment variables for ECS container (key=value). Defaults to empty."
  type        = map(string)
  default     = {}
}

variable "module_name" {
  description = "Name of the module/service (used for unique naming)"
  type        = string
}