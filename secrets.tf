resource "aws_secretsmanager_secret" "rds_secret" {
  name        = "rds-1-secret-${var.environment}"
  description = "RDS credentials for ${var.environment}"
  tags        = local.common_tags
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.rds_username,
    password = var.rds_password
  })
}