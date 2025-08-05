output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.web.name
}

output "launch_template_ami" {
  value = var.ami_id
}