# DocumentDB Module - Production Environment

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
  environment              = "production"
  vpc_id                   = dependency.vpc.outputs.vpc_id
  private_subnet_ids       = dependency.vpc.outputs.private_subnet_ids
  docdb_security_group_id  = dependency.sg.outputs.docdb_security_group_id
  master_username          = "admin"
  master_password_secret_name = "terragrunt-infra-production-docdb-master-password"
  instance_class           = "db.r6g.large"
  instances_count          = 2
  backup_retention_period  = 14
  skip_final_snapshot      = false
  deletion_protection      = true
}
