module "network" {
  source             = "./modules/network"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_app_cidr   = var.private_app_cidr
  private_db_cidr    = var.private_db_cidr
  common_tags        = local.common_tags
}

module "security" {
  source      = "./modules/security"
  vpc_id      = module.network.vpc_id
  vpc_cidr    = var.vpc_cidr
  common_tags = local.common_tags
  ssh_cidr    = local.my_ip_cidr
}

module "web" {
  source            = "./modules/web"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  web_sg_id         = module.security.web_sg_id
  instance_type     = var.instance_type
  ami_id            = var.ami_id
  environment       = var.environment 
  common_tags       = local.common_tags
}

module "secrets" {
  source        = "./modules/secrets"
  environment   = var.environment
  common_tags   = local.common_tags
  rds_username  = var.rds_username
  rds_password  = var.rds_password
}

module "rds" {
  source        = "./modules/rds"
  db_subnet_ids = module.network.private_db_subnet_ids
  vpc_id        = module.network.vpc_id
  rds_sg_id     = module.security.rds_sg_id
  username      = var.rds_username
  password      = var.rds_password
  environment   = var.environment
  common_tags   = local.common_tags
  create_iam_role   = var.create_iam_role
}

module "app" {
  source              = "./modules/app"
  vpc_id              = module.network.vpc_id
  private_subnet_ids  = module.network.private_app_subnet_ids
  app_sg_id           = module.security.app_sg_id
  rds_endpoint        = module.rds.rds_endpoint
  rds_username        = local.rds_creds.username
  rds_password        = local.rds_creds.password
  common_tags         = local.common_tags
  key_name            = var.key_name
}

module "monitoring" {
  source        = "./modules/monitoring"
  web_asg_name  = module.web.asg_name
  common_tags   = local.common_tags
}

module "alerts" {
  source         = "./modules/alerts"
  rds_identifier = module.rds.rds_identifier
  web_asg_name   = module.web.asg_name
  common_tags    = local.common_tags
}

data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}