module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
  project_name        = var.project_name
}

module "security_group" {
  source       = "./modules/security"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  cidr_block   = var.cidr_ipv4_block
}

module "compute" {
  source             = "./modules/compute"
  project_name       = var.project_name
  web_sg_id          = module.security_group.web_sg_id
  private_subnet_ids = module.vpc.private_subnet_id
  web_tg_arn         = module.lb.web_tg_arn
}

module "lb" {
  source           = "./modules/alb"
  project_name     = var.project_name
  web_sg_id        = module.security_group.web_sg_id
  public_subnet_id = module.vpc.public_subnet_id
  vpc_id           = module.vpc.vpc_id
}