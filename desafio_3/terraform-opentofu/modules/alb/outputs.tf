output "alb_sg_id" {
  description = "Security Group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "alb_tg_arn" {
  description = "Target Group ARN for Fargate"
  value       = aws_lb_target_group.fargate_tg.arn
}

output "fargate_tg_arn" {
  description = "Target Group ARN for ECS Fargate"
  value       = aws_lb_target_group.fargate_tg.arn
}