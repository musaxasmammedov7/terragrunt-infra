# ALB Module - Load Testing Environment

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "sg" {
  config_path = "../sg"
}

terraform {
  source = "../../../modules//alb"
}

inputs = {
  aws_region            = "us-east-1"
  environment           = "load-testing"
  public_subnet_ids     = dependency.vpc.outputs.public_subnet_ids
  alb_security_group_id = dependency.sg.outputs.alb_security_group_id
  health_check_path     = "/"
}
