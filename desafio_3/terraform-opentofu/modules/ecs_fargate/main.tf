# ECS IAM Role
resource "aws_iam_role" "ecs_task_execution" {
  name = format(
    "%s-%s-ecs-task-execution",
    var.tags["Environment"],
    var.module_name
  )
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
  tags = var.tags
}

# ECS Security Group
resource "aws_security_group" "ecs_sg" {
  name = format(
    "%s-%s-ecs-private-sg",
    var.tags["Environment"],
    var.module_name
  )
  description = "Allow HTTP from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# ECS Cluster
resource "aws_ecs_cluster" "fargate_cluster" {
  name = format(
    "%s-%s-fargate-cluster",
    var.tags["Environment"],
    var.module_name
  )
  tags = var.tags
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app_task" {
  family                   = format(
    "%s-%s-ecs-task",
    var.tags["Environment"],
    var.module_name
  )
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true
      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
      }]
      environment = [
        for key, value in var.environment_variables : {
          name  = key
          value = value
        }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "app_service" {
  name            = format(
    "%s-%s-ecs-service",
    var.tags["Environment"],
    var.module_name
  )
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_tg_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags = var.tags
}