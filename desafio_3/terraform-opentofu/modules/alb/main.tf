# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name = format(
    "%s-%s-alb-sg",
    var.tags["Environment"],
    var.module_name
  )
  description = "Allow HTTP from internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.alb_port
    to_port     = var.alb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# ALB
resource "aws_lb" "alb" {
  name = format(
    "%s-%s-alb",
    var.tags["Environment"],
    var.module_name
  )
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
  enable_deletion_protection = false
  tags = var.tags
}

# Target Group
resource "aws_lb_target_group" "fargate_tg" {
  name = format(
    "%s-%s-fargate-tg",
    var.tags["Environment"],
    var.module_name
  )
  port        = var.alb_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.target_path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = var.tags
}

# Listener
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fargate_tg.arn
  }
}