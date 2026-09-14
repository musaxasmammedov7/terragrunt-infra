# EC2/Autoscaling Module - Production Environment

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "sg" {
  config_path = "../sg"
}

dependency "alb" {
  config_path = "../alb"
}

terraform {
  source = "../../../modules//ec2"
}

inputs = {
  aws_region            = "us-east-1"
  environment           = "production"
  instance_type         = "t3.small"
  key_name              = ""
  min_size              = 2
  max_size              = 6
  desired_capacity      = 3
  private_subnet_ids    = dependency.vpc.outputs.private_subnet_ids
  ec2_security_group_id = dependency.sg.outputs.ec2_security_group_id
  target_group_arn      = dependency.alb.outputs.target_group_arn
}
