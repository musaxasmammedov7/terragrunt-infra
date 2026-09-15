# Inspector Module - Load Testing Environment

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules//inspector"
}

inputs = {
  aws_region          = "us-east-1"
  environment         = "load-testing"
  notification_email_secret_name = "terragrunt-infra-load-testing-notification-email"
}
