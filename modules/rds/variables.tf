variable "db_subnet_ids" {
  description = "Subnets for RDS DB subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "rds_sg_id" {
  description = "Security Group ID for RDS"
  type        = string
}

variable "username" {
  description = "RDS master username"
  type        = string
}

variable "password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}