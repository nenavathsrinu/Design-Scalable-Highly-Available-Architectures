
output "secret_string" {
  value     = aws_secretsmanager_secret_version.rds_version.secret_string
  sensitive = true
}
