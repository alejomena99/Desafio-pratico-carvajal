# -------------------------------
# External VPC remote state
# -------------------------------
locals {
  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets         = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  private_subnets        = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  private_route_table_id = data.terraform_remote_state.vpc.outputs.private_route_table_id
}

# -------------------------------
# NAT Gateway
# -------------------------------
module "nat_gateway" {
  source                 = "./modules/nat_gateway"
  project_name           = var.project_name
  module_name            = "nat"                       # <-- agregado
  tags                   = var.tags
  public_subnet_ids      = local.public_subnets
  private_route_table_id = local.private_route_table_id
  nat_index              = 1
}

# -------------------------------
# Application Load Balancer (Dashboard)
# -------------------------------
module "alb_dashboard" {
  source            = "./modules/alb"
  project_name      = var.project_name
  module_name       = "dashboard" 
  tags              = var.tags
  vpc_id            = local.vpc_id
  public_subnet_ids = local.public_subnets
  alb_port          = 80
  target_path       = "/"
}

# -------------------------------
# Application Load Balancer (Gateway)
# -------------------------------
module "alb_gateway" {
  source            = "./modules/alb"
  project_name      = var.project_name
  module_name       = "gateway"  
  tags              = var.tags
  vpc_id            = local.vpc_id
  public_subnet_ids = local.public_subnets
  alb_port          = 80
  target_path       = "/"
}


# -------------------------------
# ECS Fargate Service (Gateway)
# -------------------------------
module "ecs_gateway" {
  source             = "./modules/ecs_fargate"
  project_name       = var.project_name
  module_name        = "gateway"
  tags               = var.tags
  private_subnet_ids = local.private_subnets
  vpc_id             = local.vpc_id
  alb_tg_arn         = module.alb_gateway.fargate_tg_arn
  alb_sg_id          = module.alb_gateway.alb_sg_id

  container_image       = "alejomena99/fox-jokes-gateway:latest"
  container_name        = "fox-jokes-gateway"
  container_port        = 80
  cpu                   = "256"
  memory                = "512"
  desired_count         = 1
}

# -------------------------------
# ECS Fargate Service (Dashboard)
# -------------------------------
module "ecs_dashboard" {
  source             = "./modules/ecs_fargate"
  project_name       = var.project_name
  module_name        = "dashboard" 
  tags               = var.tags
  private_subnet_ids = local.private_subnets
  vpc_id             = local.vpc_id
  alb_tg_arn         = module.alb_dashboard.fargate_tg_arn
  alb_sg_id          = module.alb_dashboard.alb_sg_id

  container_image       = "alejomena99/fox-jokes-dashboard:latest"
  container_name        = "fox-jokes-dashboard"
  container_port        = 80
  cpu                   = "256"
  memory                = "512"
  desired_count         = 1
  environment_variables = {
    API_URL = "http://${module.alb_gateway.alb_dns_name}"
  }
}
