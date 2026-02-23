module "vpc" {
  source              = "../../modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
  project_name        = var.project_name
}

module "security_group" {
  source       = "../../modules/security"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "compute" {
  source                    = "../../modules/compute"
  project_name              = var.project_name
  instance_type             = "t3.micro"
  web_sg_id                 = module.security_group.web_sg_id
  private_subnet_ids        = module.vpc.private_subnet_id
  web_tg_arn                = module.lb.web_tg_arn
  rds_endpoint              = module.rds.rds_endpoint
  eic_sg_id                 = module.security_group.eic_sg_id
  iam_instance_profile_name = module.iam.instance_profile_name
  artifact_bucket_name      = module.s3.bucket_name
  db_username               = var.db_username
  db_password               = var.db_password
  db_name                   = var.db_name
  environment               = var.environment
}

module "lb" {
  source           = "../../modules/alb"
  project_name     = var.project_name
  alb_sg_id        = module.security_group.alb_sg_id
  public_subnet_id = module.vpc.public_subnet_id
  vpc_id           = module.vpc.vpc_id
  certificate_arn  = module.dns.certificate_arn
}

module "dns" {
  source       = "../../modules/dns"
  domain_name  = var.domain_name
  alb_dns_name = module.lb.alb_dns_name
  alb_zone_id  = module.lb.alb_zone_id
}

module "rds" {
  source             = "../../modules/rds"
  project_name       = var.project_name
  rds_sg_id          = module.security_group.rds_sg_id
  private_subnet_ids = module.vpc.private_subnet_id
  db_password        = var.db_password
  db_username        = var.db_username
  db_name            = var.db_name
}

module "s3" {
  source       = "../../modules/s3"
  environment  = var.environment
  project_name = var.project_name
}

module "iam" {
  source        = "../../modules/iam"
  environment   = var.environment
  s3_bucket_arn = module.s3.bucket_arn
}

