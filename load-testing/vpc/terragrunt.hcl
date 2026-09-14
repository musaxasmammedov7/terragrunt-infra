# VPC Module - Load Testing Environment

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules//vpc"
}

inputs = {
  aws_region          = "us-east-1"
  environment         = "load-testing"
  vpc_cidr            = "10.20.0.0/16"
  public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnet_cidrs = ["10.20.3.0/24", "10.20.4.0/24"]
}
