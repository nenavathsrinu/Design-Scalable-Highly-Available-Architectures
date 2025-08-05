variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
}

variable "web_sg_id" {
  description = "Security Group ID for web instances"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ASG"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "environment" {
  description = "Environment name (dev, qa, stg, prod)"
  type        = string
}