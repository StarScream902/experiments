include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git//?ref=v3.19.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

inputs = {
  name            = "test"
  cidr            = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = local.env_vars.locals.environment.full
  }
}
