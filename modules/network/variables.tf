variable "vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "private_app_cidr" {
  description = "CIDR block for private app subnet"
  type        = string
}

variable "private_db_cidr" {
  description = "CIDR block for private db subnet"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}