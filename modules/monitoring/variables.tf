variable "web_asg_name" {
  description = "Name of the web Auto Scaling Group"
  type        = string
}

variable "common_tags" {
  type = map(string)
}
