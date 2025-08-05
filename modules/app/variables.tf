variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_sg_id" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "common_tags" {
  type = map(string)
}

variable "key_name" {
  description = "EC2 Key Pair Name"
  type        = string
}
