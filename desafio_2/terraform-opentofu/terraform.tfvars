public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
vpc_cidrs = "10.0.0.0/16"
tags = { Terraform = "true", Environment = "dev" }
name = "test"
region = "us-west-2"