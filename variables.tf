variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_app_cidr" {
  type = string
}

variable "private_db_cidr" {
  type = string
}

variable "instance_type" {
  default = "t2.micro"
}

variable "rds_username" {
  type        = string
  description = "RDS master username"
}

variable "rds_password" {
  type        = string
  sensitive   = true
  description = "RDS master password"
}

variable "environment" {
  description = "The environment to deploy (dev, qa, stg, prod)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances in launch template"
  type        = string
}
variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}
variable "create_iam_role" {
  description = "Conditionally create IAM role for RDS monitoring"
  type        = bool
  default     = false
}

variable "ssh_cidr" {
  type        = string
  description = "CIDR block allowed to SSH"
}