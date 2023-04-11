include "root" {
  path    = find_in_parent_folders()
  expose  = true
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git//?ref=v4.3.0"
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../..//vpc"
}

dependency "key_pair" {
  config_path = "${get_terragrunt_dir()}/../..//key_pair"
}

# Security Groups ############################################
dependency "internet-to-pub-ssh" {
  config_path = "${get_terragrunt_dir()}/../..//sg/internet-to-pub-ssh"
}

dependency "egress-to-anywhere" {
  config_path = "${get_terragrunt_dir()}/../..//sg/egress-to-anywhere"
}
#################################################################

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

inputs = {
  name = "test"

  ami                     = "ami-00c39f71452c08778"
  instance_type           = "t2.micro"
  key_name                = dependency.key_pair.outputs.key_pair_name
  monitoring              = true
  vpc_security_group_ids  = [
    dependency.egress-to-anywhere.outputs.security_group_id,
    dependency.internet-to-pub-ssh.outputs.security_group_id
    ]
  subnet_id               = dependency.vpc.outputs.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = local.env_vars.locals.environment.full
  }
}
