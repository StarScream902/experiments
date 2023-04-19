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
  eks_cluster_oidc_issuer_url           = dependency.cluster.outputs.cluster_oidc_issuer_url
  eks_cluster_oidc_provider_arn  = dependency.cluster.outputs.oidc_provider_arn

  vpc_id            = dependency.vpc.outputs.vpc_id
  aws_region        = local.env_vars.locals.region
}
