# Inspector Module - Dev Environment

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//inspector"
}

inputs = {
  aws_region          = "us-east-1"
  environment         = "dev"
  notification_email_secret_name = "terragrunt-infra-dev-notification-email"
}
