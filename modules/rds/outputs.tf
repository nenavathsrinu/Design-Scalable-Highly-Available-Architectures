output "rds_identifier" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.myapp_rds.identifier
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.myapp_rds.endpoint
}

output "rds_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.myapp_rds.arn
}
