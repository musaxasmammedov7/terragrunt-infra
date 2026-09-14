# Security Groups Module - Production Environment

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../../vpc"
}

terraform {
  source = "../../../modules//sg"
}

inputs = {
  aws_region  = "us-east-1"
  environment = "production"
  vpc_id      = dependency.vpc.outputs.vpc_id
}
