variable "web_asg_name" {
  description = "Name of the Auto Scaling Group for the web tier"
  type        = string
}

variable "rds_identifier" {
  description = "The identifier of the RDS instance to monitor for failover events"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
}
