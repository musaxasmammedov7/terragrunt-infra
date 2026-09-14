# VPC Module - Production Environment

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules//vpc"
}

inputs = {
  aws_region          = "us-east-1"
  environment         = "production"
  vpc_cidr            = "10.10.0.0/16"
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.3.0/24", "10.10.4.0/24"]
}
