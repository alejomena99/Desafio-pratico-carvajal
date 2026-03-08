output "ecs_cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.fargate_cluster.id
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.app_service.name
}

output "ecs_task_definition_arn" {
  description = "ECS Task Definition ARN"
  value       = aws_ecs_task_definition.app_task.arn
}

output "ecs_sg_id" {
  description = "ECS Security Group ID"
  value       = aws_security_group.ecs_sg.id
}