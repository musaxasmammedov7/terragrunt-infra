# DocumentDB Module - Dev Environment

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
  source = "../../../modules//docdb"
}

inputs = {
  aws_region               = "us-east-1"
  environment              = "dev"
  vpc_id                   = dependency.vpc.outputs.vpc_id
  private_subnet_ids       = dependency.vpc.outputs.private_subnet_ids
  docdb_security_group_id  = dependency.sg.outputs.docdb_security_group_id
  master_username          = "admin"
  master_password          = "dev-docdb-password-2024"
  instance_class           = "db.t3.medium"
  instances_count          = 1
  backup_retention_period  = 7
  skip_final_snapshot      = true
  deletion_protection      = false
}
