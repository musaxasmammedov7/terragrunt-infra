# CloudWatch Module - Dev Environment

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
  environment            = "dev"
  cpu_target_value       = 70
  notification_email_secret_name = "terragrunt-infra-dev-notification-email"
  autoscaling_group_name = dependency.ec2.outputs.autoscaling_group_name
  alb_arn_suffix         = dependency.alb.outputs.alb_arn_suffix
}
