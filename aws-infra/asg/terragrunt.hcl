include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-autoscaling.git/?ref=v6.9.0"
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/..//vpc"
}

dependency "key_pair" {
  config_path = "${get_terragrunt_dir()}/..//key_pair"
}

dependency "alb" {
  config_path = "${get_terragrunt_dir()}/..//alb"
}

# Security Groups ############################################
dependency "pub-to-asg-ssh" {
  config_path = "${get_terragrunt_dir()}/..//sg/pub-to-asg-ssh"
}

dependency "pub-to-asg-http" {
  config_path = "${get_terragrunt_dir()}/..//sg/pub-to-asg-http"
}

dependency "egress-to-anywhere" {
  config_path = "${get_terragrunt_dir()}/..//sg/egress-to-anywhere"
}
#################################################################

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
}

inputs = {
  name = "example-asg"

  min_size                  = 1
  desired_capacity          = 2
  max_size                  = 4
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = dependency.vpc.outputs.private_subnets

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 120
      min_healthy_percentage = 50
    }
  }

  scaling_policies = {
    avg-cpu-policy-greater-than-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 300
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    }
  }

  # Launch template
  launch_template_name        = "example-asg"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id          = "ami-00c39f71452c08778"
  instance_type     = "t2.micro"
  ebs_optimized     = false
  user_data         = filebase64("user_data.sh")
  key_name          = dependency.key_pair.outputs.key_pair_name
  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [
        dependency.pub-to-asg-ssh.outputs.security_group_id,
        dependency.pub-to-asg-http.outputs.security_group_id,
        dependency.egress-to-anywhere.outputs.security_group_id
      ]
    }
  ]

  # Load balancing
  target_group_arns = dependency.alb.outputs.target_group_arns
}
