# Inspector Module - Production Environment

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//inspector"
}

inputs = {
  aws_region          = "us-east-1"
  environment         = "production"
  notification_email  = ""
}
