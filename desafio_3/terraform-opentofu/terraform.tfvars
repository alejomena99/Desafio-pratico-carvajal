region            = "us-west-2"
project_name      = "desafio3"

# Tags must include Environment and Terraform keys
tags = {
  Environment = "dev"
  Terraform   = "true"
}

vpc_state_bucket  = "carvajal-tfstate-s3"
vpc_state_key     = "desafio2/terraform.tfstate"
vpc_state_region  = "us-west-2"