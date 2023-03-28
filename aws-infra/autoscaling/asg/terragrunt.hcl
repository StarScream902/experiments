include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git/?ref=v3.19.0"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

inputs = {
  
}
