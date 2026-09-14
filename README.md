# Task 2: Terragrunt Infrastructure

AWS infrastructure for Node.js demo app managed with Terragrunt across multiple environments.

## Structure

```
terragrunt/
├── root.hcl                    # Shared config (remote_state, generate)
├── modules/                    # Terraform modules
│   ├── vpc/main.tf
│   ├── sg/main.tf
│   ├── alb/main.tf
│   ├── ec2/main.tf
│   └── cloudwatch/main.tf
├── env/                        # Variable files
│   ├── dev.tfvars
│   ├── production.tfvars
│   └── load-testing.tfvars
├── dev/                        # Development
│   ├── vpc/terragrunt.hcl
│   └── app/{sg,alb,ec2,cloudwatch}/
├── production/                 # Production
│   ├── vpc/terragrunt.hcl
│   └── app/{sg,alb,ec2,cloudwatch}/
└── load-testing/               # Load testing (new)
    ├── vpc/terragrunt.hcl
    └── app/{sg,alb,ec2,cloudwatch}/
```

## How It Works

### root.hcl

Defines shared configuration inherited by all units via `include` block:

```hcl
remote_state {
  backend = "s3"
  config = {
    bucket = "musaxasmammedov-terragrunt-state"
    key    = "${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "provider" {
  contents = <<EOF
provider "aws" { region = var.aws_region }
EOF
}
```

### Child Units

Each unit includes root config and defines its own inputs:

```hcl
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
  environment = "dev"
  vpc_id      = dependency.vpc.outputs.vpc_id
}
```

## Environments

| Environment | Instance Type | Min/Max | Purpose |
|---|---|---|---|
| dev | t3.micro | 1-3 | Development |
| production | t3.small | 2-6 | Production |
| load-testing | t3.medium | 2-10 | Performance testing |

## Usage

```bash
# Install
brew install terragrunt

# Deploy dev
cd dev
terragrunt run-all apply

# Deploy production
cd production
terragrunt run-all apply

# Deploy load-testing
cd load-testing
terragrunt run-all apply
```

## Cost Estimation

```bash
brew install infracost
infracost auth login
cd terragrunt
infracost breakdown --config infracost.yml
```
