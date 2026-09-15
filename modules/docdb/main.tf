###############################################################################
# DocumentDB Module
# Creates: DocumentDB Cluster, Instance, Subnet Group
###############################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for DocumentDB"
  type        = list(string)
}

variable "docdb_security_group_id" {
  description = "Security group ID for DocumentDB"
  type        = string
}

variable "master_username" {
  description = "Master username for DocumentDB"
  type        = string
  default     = "admin"
}

variable "master_password_secret_name" {
  description = "Name of the AWS Secrets Manager secret containing the DocumentDB master password"
  type        = string
}

variable "instance_class" {
  description = "DocumentDB instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "instances_count" {
  description = "Number of DocumentDB instances"
  type        = number
  default     = 1
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

locals {
  name_prefix = "nodejs-demoapp-${var.environment}"
}

###############################################################################
# Secrets from AWS Secrets Manager
###############################################################################
data "aws_secretsmanager_secret" "master_password" {
  name = var.master_password_secret_name
}

data "aws_secretsmanager_secret_version" "master_password" {
  secret_id = data.aws_secretsmanager_secret.master_password.id
}

locals {
  master_password = data.aws_secretsmanager_secret_version.master_password.secret_string
}

###############################################################################
# DocumentDB Subnet Group
###############################################################################
resource "aws_docdb_subnet_group" "main" {
  name       = "${local.name_prefix}-docdb-subnet"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${local.name_prefix}-docdb-subnet-group"
  }
}

###############################################################################
# DocumentDB Parameter Group
###############################################################################
resource "aws_docdb_cluster_parameter_group" "main" {
  family = "docdb5.0"
  name   = "${local.name_prefix}-docdb-params"

  parameter {
    name  = "tls"
    value = "enabled"
  }

  tags = {
    Name = "${local.name_prefix}-docdb-parameter-group"
  }
}

###############################################################################
# DocumentDB Cluster
###############################################################################
resource "aws_docdb_cluster" "main" {
  cluster_identifier      = "${local.name_prefix}-docdb"
  engine                  = "docdb"
  master_username         = var.master_username
  master_password         = local.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  storage_encrypted       = true

  vpc_security_group_ids = [var.docdb_security_group_id]
  db_subnet_group_name    = aws_docdb_subnet_group.main.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name

  tags = {
    Name = "${local.name_prefix}-docdb-cluster"
  }
}

###############################################################################
# DocumentDB Instance(s)
###############################################################################
resource "aws_docdb_cluster_instance" "main" {
  count              = var.instances_count
  identifier         = "${local.name_prefix}-docdb-${count.index}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.instance_class

  tags = {
    Name = "${local.name_prefix}-docdb-instance-${count.index}"
  }
}

###############################################################################
# Outputs
###############################################################################
output "cluster_endpoint" {
  value = aws_docdb_cluster.main.endpoint
}

output "cluster_reader_endpoint" {
  value = aws_docdb_cluster.main.reader_endpoint
}

output "cluster_port" {
  value = aws_docdb_cluster.main.port
}

output "cluster_id" {
  value = aws_docdb_cluster.main.id
}

output "cluster_arn" {
  value = aws_docdb_cluster.main.arn
}

output "connection_string" {
  value     = "mongodb://${var.master_username}:${local.master_password}@${aws_docdb_cluster.main.endpoint}:27017/?tls=true&replicaSet=rs0&readPreference=secondaryPreferred"
  sensitive = true
}
