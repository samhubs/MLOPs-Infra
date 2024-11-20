# terraform/main.tf

# terraform/main.tf

provider "aws" {
  region = var.aws_region
}


# Get current caller identity
data "aws_caller_identity" "current" {}

# Get availability zones
data "aws_availability_zones" "available" {}

module "networking" {
  source = "./modules/networking"

  vpc_name             = "mlops-vpc"
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = data.aws_availability_zones.available.names
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  environment          = "dev"
}

module "eks" {
  source = "./modules/eks"

  cluster_name        = "mlops-eks-cluster"
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  environment         = "dev"
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "yolo-skeleton-detection"
  environment     = "dev"
}
