resource "aws_secretsmanager_secret" "rds" {
  name        = "rds-${var.environment}-secret"
  description = "RDS credentials for ${var.environment}"
  tags        = var.common_tags
}

resource "aws_secretsmanager_secret_version" "rds_version" {
  secret_id     = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = var.rds_username
    password = var.rds_password
  })
}
