# Load Testing Environment - Terraform Variables

environment         = "load-testing"
aws_region          = "us-east-1"
project_name        = "nodejs-demoapp"

# VPC
vpc_cidr            = "10.20.0.0/16"
public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs = ["10.20.3.0/24", "10.20.4.0/24"]

# EC2
instance_type       = "t3.medium"
key_name            = ""
min_size            = 2
max_size            = 10
desired_capacity    = 3

# ALB
health_check_path   = "/"

# Scaling
cpu_target_value    = 60

# Notifications
notification_email  = ""
