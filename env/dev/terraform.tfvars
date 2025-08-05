aws_region         = "ap-south-1"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
private_app_cidr   = "10.0.2.0/24"
private_db_cidr    = "10.0.5.0/24"
environment        = "dev"

rds_username       = "admin"
rds_password       = "SuperSecurePassword123!"  # avoid hardcoding this in real life