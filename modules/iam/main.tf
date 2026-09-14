###############################################################################
# IAM Module
# Creates: IAM Role, Policy for EC2 to communicate with DocumentDB
###############################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "docdb_cluster_arn" {
  description = "ARN of the DocumentDB cluster"
  type        = string
}

locals {
  name_prefix = "nodejs-demoapp-${var.environment}"
}

###############################################################################
# IAM Role for EC2
###############################################################################
resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "${local.name_prefix}-ec2-role"
  }
}

###############################################################################
# Policy: EC2 to DocumentDB
###############################################################################
resource "aws_iam_policy" "ec2_docdb" {
  name        = "${local.name_prefix}-ec2-docdb-policy"
  description = "Policy for EC2 instances to communicate with DocumentDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DocumentDBConnect"
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = [
          "${var.docdb_cluster_arn}:*"
        ]
      },
      {
        Sid    = "DocumentDBDescribe"
        Effect = "Allow"
        Action = [
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "rds:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-ec2-docdb-policy"
  }
}

###############################################################################
# Policy: CloudWatch Logs
###############################################################################
resource "aws_iam_policy" "cloudwatch_logs" {
  name        = "${local.name_prefix}-cloudwatch-logs-policy"
  description = "Policy for EC2 instances to write CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-cloudwatch-logs-policy"
  }
}

###############################################################################
# Policy: SSM Session Manager
###############################################################################
resource "aws_iam_policy" "ssm" {
  name        = "${local.name_prefix}-ssm-policy"
  description = "Policy for EC2 SSM Session Manager access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMAccess"
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-ssm-policy"
  }
}

###############################################################################
# Attach Policies to Role
###############################################################################
resource "aws_iam_role_policy_attachment" "ec2_docdb" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_docdb.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs.arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ssm.arn
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

###############################################################################
# Instance Profile
###############################################################################
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name = "${local.name_prefix}-ec2-profile"
  }
}

###############################################################################
# Outputs
###############################################################################
output "ec2_role_arn" {
  value = aws_iam_role.ec2_role.arn
}

output "ec2_role_name" {
  value = aws_iam_role.ec2_role.name
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_docdb_policy_arn" {
  value = aws_iam_policy.ec2_docdb.arn
}
