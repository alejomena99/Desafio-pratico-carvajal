variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-west-2"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "vpc_cidrs" {
  type        = string
  description = "VPC CIDR block"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}

variable "tags" {
  type = map(string)
  description = "Tags to apply to resources"
}

variable "name" {
  type        = string
  description = "VPC tag name"
}