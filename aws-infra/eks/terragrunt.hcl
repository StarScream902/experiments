include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-eks.git//?ref=v19.12.0"
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../..//vpc"
}

# Security Groups ############################################
dependency "pub-to-asg-http" {
  config_path = "${get_terragrunt_dir()}/..//sg/pub-to-asg-http"
}

dependency "egress-to-anywhere" {
  config_path = "${get_terragrunt_dir()}/..//sg/egress-to-anywhere"
}
##############################################################

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  vars = read_terragrunt_config(find_in_parent_folders("vars.hcl"))
}

inputs = {
  cluster_name    = "example-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = local.vars.locals.cluster_endpoint_public_access_cidrs

  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets

  cluster_addons = {
    aws-ebs-csi-driver = {
      addon_version = "v1.14.2-eksbuild.1"
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
  }
}
