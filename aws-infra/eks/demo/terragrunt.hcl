include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "cluster" {
  config_path = "${get_terragrunt_dir()}/..//cluster"
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../..//vpc"
}

terraform {
  source = ".//module"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

inputs = {
  environment                           = local.env_vars.locals.environment
  eks_cluster_id                        = dependency.cluster.outputs.cluster_name
}
