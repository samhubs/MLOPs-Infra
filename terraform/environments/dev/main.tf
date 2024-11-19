provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  vpc_cidr = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "ec2" {
  source = "../../modules/ec2"

  environment   = var.environment
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[0]  # Using first public subnet
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
}

module "mlflow" {
  source = "../../modules/mlflow"

  environment        = var.environment
  aws_region        = var.aws_region
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  
  db_username     = var.db_username
  db_password     = var.db_password
}