###############################################################################
# AWS Inspector Module
# Creates: Inspector2 Enable, Findings Filter, SNS Topic for Alerts
###############################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "notification_email" {
  description = "Email for Inspector findings"
  type        = string
  default     = ""
}

variable "ec2_instance_arns" {
  description = "List of EC2 instance ARNs to scan"
  type        = list(string)
  default     = []
}

locals {
  name_prefix = "nodejs-demoapp-${var.environment}"
}

data "aws_caller_identity" "current" {}

###############################################################################
# Enable AWS Inspector2
###############################################################################
resource "aws_inspector2_enabler" "main" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["EC2", "ECR"]
}

###############################################################################
# SNS Topic for Inspector Findings
###############################################################################
resource "aws_sns_topic" "inspector_findings" {
  name = "${local.name_prefix}-inspector-findings"

  tags = {
    Name = "${local.name_prefix}-inspector-findings"
  }
}

resource "aws_sns_topic_policy" "inspector_findings" {
  arn = aws_sns_topic.inspector_findings.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowInspectorPublish"
        Effect    = "Allow"
        Principal = { Service = "inspector2.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.inspector_findings.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.inspector_findings.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

###############################################################################
# Inspector Findings Filter - Critical/High findings
###############################################################################
resource "aws_inspector2_filter" "critical_high" {
  name   = "${local.name_prefix}-critical-high-findings"
  action = "NONE"

  filter_criteria {
    severity {
      comparison = "EQUALS"
      value      = "CRITICAL"
    }
  }

  filter_criteria {
    severity {
      comparison = "EQUALS"
      value      = "HIGH"
    }
  }

  tags = {
    Name = "${local.name_prefix}-inspector-filter"
  }
}

###############################################################################
# CloudWatch Alarms for Inspector Findings
###############################################################################
resource "aws_cloudwatch_metric_alarm" "inspector_findings" {
  alarm_name          = "${local.name_prefix}-inspector-findings"
  alarm_description   = "Inspector detected critical or high findings"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "findings_count"
  namespace           = "AWS/Inspector2"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_actions       = [aws_sns_topic.inspector_findings.arn]
  ok_actions          = [aws_sns_topic.inspector_findings.arn]

  tags = {
    Name = "${local.name_prefix}-inspector-alarm"
  }
}

###############################################################################
# Outputs
###############################################################################
output "inspector_enabled" {
  value = aws_inspector2_enabler.main.id
}

output "inspector_findings_topic_arn" {
  value = aws_sns_topic.inspector_findings.arn
}

output "inspector_filter_id" {
  value = aws_inspector2_filter.critical_high.id
}
