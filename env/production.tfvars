# Production Environment - Terraform Variables

environment         = "production"
aws_region          = "us-east-1"
project_name        = "nodejs-demoapp"

# VPC
vpc_cidr            = "10.10.0.0/16"
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.3.0/24", "10.10.4.0/24"]

# EC2
instance_type       = "t3.small"
key_name            = ""
min_size            = 2
max_size            = 6
desired_capacity    = 3

# ALB
health_check_path   = "/"

# Scaling
cpu_target_value    = 65

# Notifications
notification_email  = ""
