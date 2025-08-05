variable "environment" {
  description = "Environment name (e.g., dev, qa, prod)"
  type        = string
}

variable "rds_username" {
  description = "RDS username"
  type        = string
  sensitive   = true
}

variable "rds_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags applied to resources"
  type        = map(string)
}