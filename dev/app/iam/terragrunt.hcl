# IAM Module - Dev Environment

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "docdb" {
  config_path = "../docdb"
}

terraform {
  source = "../../../modules//iam"
}

inputs = {
  aws_region      = "us-east-1"
  environment     = "dev"
  docdb_cluster_arn = dependency.docdb.outputs.cluster_arn
}
