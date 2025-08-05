# --------------------------------------
# IAM Role (create only if not exists)
# --------------------------------------
resource "aws_iam_role" "rds_monitoring" {
  count = var.create_iam_role ? 1 : 0

  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    { Name = "rds-monitoring-role" },
    var.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "monitoring_attach" {
  count      = var.create_iam_role ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# --------------------------------------
# Always reference the role (whether created or not)
# --------------------------------------
data "aws_iam_role" "rds_monitoring_existing" {
  name       = "rds-monitoring-role"
  depends_on = [aws_iam_role.rds_monitoring] # ensure role creation happens first if needed
}

# --------------------------------------
# RDS Subnet Group
# --------------------------------------
resource "aws_db_subnet_group" "this" {
  name       = "rds-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = merge(
    { Name = "rds-subnet-group" },
    var.common_tags
  )
}

# --------------------------------------
# Parameter Group
# --------------------------------------
resource "aws_db_parameter_group" "mysql_custom" {
  name        = "myapp-mysql-params"
  family      = "mysql8.0"
  description = "Custom parameter group for MySQL"

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "log_queries_not_using_indexes"
    value = "1"
  }

  parameter {
    name  = "log_output"
    value = "TABLE"
  }

  tags = merge(
    { Name = "mysql-param-group" },
    var.common_tags
  )
}

# --------------------------------------
# RDS Instance
# --------------------------------------
resource "aws_db_instance" "myapp_rds" {
  identifier              = "myapp-rds-${var.environment}"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.medium"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = var.username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.rds_sg_id]
  multi_az                = true
  publicly_accessible     = false
  parameter_group_name    = aws_db_parameter_group.mysql_custom.name
  apply_immediately       = true
  skip_final_snapshot     = true
  deletion_protection     = false

  backup_retention_period         = 7
  backup_window                   = "03:00-04:00"
  monitoring_interval             = 60
  monitoring_role_arn             = data.aws_iam_role.rds_monitoring_existing.arn
  performance_insights_enabled    = true
  enabled_cloudwatch_logs_exports = ["slowquery", "error", "general"]

  depends_on = [aws_db_parameter_group.mysql_custom]

  tags = merge(
    { Name = "myapp-rds-${var.environment}" },
    var.common_tags
  )
}