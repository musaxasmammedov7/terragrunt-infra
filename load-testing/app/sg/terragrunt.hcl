# Security Groups Module - Load Testing Environment

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
  environment = "load-testing"
  vpc_id      = dependency.vpc.outputs.vpc_id
}
