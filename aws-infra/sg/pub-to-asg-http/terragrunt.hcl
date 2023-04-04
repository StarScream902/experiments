include "root" {
  path    = find_in_parent_folders()
  expose  = true
}

terraform {
  source = "git@github.com:terraform-aws-modules/terraform-aws-security-group.git/?ref=v4.17.1"
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../..//vpc"
}

inputs = {
  name        = "pub-to-asg-http"
  description = "allow http trafic from public networks"
  vpc_id      = dependency.vpc.outputs.vpc_id

  # Allow ingress rules to be accessed only within current VPC
  ingress_cidr_blocks = dependency.vpc.outputs.public_subnets

  # Allow all rules for all protocols
  ingress_rules = ["http-80-tcp"]
}
