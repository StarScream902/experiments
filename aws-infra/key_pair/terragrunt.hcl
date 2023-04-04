include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@github.com:terraform-aws-modules//terraform-aws-key-pair.git/?ref=v2.0.2"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  ssh_keys = read_terragrunt_config("ssh_keys/list.hcl")

}

inputs = {
  key_name    = "starscream902_aws_test"
  public_key  = local.ssh_keys.locals.starscream902_aws_test
  tags = {
    Terraform   = "true"
    Environment = local.env_vars.locals.environment.full
  }
}
