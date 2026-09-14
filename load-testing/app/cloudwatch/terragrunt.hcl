# CloudWatch Module - Load Testing Environment

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "ec2" {
  config_path = "../ec2"
}

dependency "alb" {
  config_path = "../alb"
}

terraform {
  source = "../../../modules//cloudwatch"
}

inputs = {
  aws_region             = "us-east-1"
  environment            = "load-testing"
  cpu_target_value       = 60
  notification_email     = ""
  autoscaling_group_name = dependency.ec2.outputs.autoscaling_group_name
  alb_arn_suffix         = dependency.alb.outputs.alb_arn_suffix
}
