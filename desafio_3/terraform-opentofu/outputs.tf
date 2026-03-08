# -------------------------------
# External IaC VPC info
# -------------------------------
output "vpc_id" {
  value       = local.vpc_id
  description = "ID of the VPC from remote state"
}

output "public_subnets" {
  value       = local.public_subnets
  description = "List of public subnet IDs from remote VPC"
}

output "private_subnets" {
  value       = local.private_subnets
  description = "List of private subnet IDs from remote VPC"
}

# -------------------------------
# ALB DNS names
# -------------------------------
output "alb_dashboard_dns_name" {
  value       = module.alb_dashboard.alb_dns_name
  description = "DNS name of the Dashboard ALB"
}

output "alb_gateway_dns_name" {
  value       = module.alb_gateway.alb_dns_name
  description = "DNS name of the Gateway ALB"
}

# -------------------------------
# ALB Target Group ARNs
# -------------------------------
output "alb_dashboard_tg_arn" {
  value       = module.alb_dashboard.alb_tg_arn
  description = "Target group ARN of the Dashboard ALB"
}

output "alb_gateway_tg_arn" {
  value       = module.alb_gateway.alb_tg_arn
  description = "Target group ARN of the Gateway ALB"
}

# -------------------------------
# ALB Security Group IDs
# -------------------------------
output "alb_dashboard_sg_id" {
  value       = module.alb_dashboard.alb_sg_id
  description = "Security Group ID of the Dashboard ALB"
}

output "alb_gateway_sg_id" {
  value       = module.alb_gateway.alb_sg_id
  description = "Security Group ID of the Gateway ALB"
}