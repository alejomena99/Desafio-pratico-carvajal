variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for NAT Gateway placement"
  type        = list(string)
}

variable "private_route_table_id" {
  description = "Private route table ID to add NAT route"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to resources (should include Environment and Terraform keys)"
  type        = map(string)
}

variable "nat_index" {
  description = "Index number for multiple NAT Gateways"
  type        = number
  default     = 1
}

variable "module_name" {
  description = "Name of the module/service (used for unique naming)"
  type        = string
}