# EC2/Autoscaling Module - Dev Environment

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

dependency "iam" {
  config_path = "../iam"
}

dependency "docdb" {
  config_path = "../docdb"
}

terraform {
  source = "../../../modules//ec2"
}

inputs = {
  aws_region                = "us-east-1"
  environment               = "dev"
  instance_type             = "t3.micro"
  key_name                  = ""
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  private_subnet_ids        = dependency.vpc.outputs.private_subnet_ids
  ec2_security_group_id     = dependency.sg.outputs.ec2_security_group_id
  target_group_arn          = dependency.alb.outputs.target_group_arn
  iam_instance_profile_name = dependency.iam.outputs.ec2_instance_profile_name
  docdb_connection_string   = dependency.docdb.outputs.connection_string
  docdb_db_name             = "todoDb"
}
