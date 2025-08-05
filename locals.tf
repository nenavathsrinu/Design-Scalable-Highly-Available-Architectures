locals {
  rds_creds = jsondecode(module.secrets.secret_string)

  common_tags = {
    Project     = "HA-Terraform-App"
    Environment = var.environment
    Owner       = "Nenavath Srinu"
    ManagedBy   = "Terraform"
  }
}