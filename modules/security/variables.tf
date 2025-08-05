variable "vpc_id" {
  description = "VPC ID where SGs will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC for ingress rules"
  type        = string
}

variable "common_tags" {
  description = "Tags to apply to all security groups"
  type        = map(string)
}