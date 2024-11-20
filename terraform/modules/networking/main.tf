module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = var.vpc_name
    cidr = var.vpc_cidr
    azs = var.availability_zones
    private_subnets = var.private_subnet_cidrs
    public_subnets = var.public_subnet_cidrs

    enable_nat_gateway = true
    single_nat_gateway = false

    tags = {
        Environment = var.environment
        terraform = true
    }
}

resource "aws_eip" "nat" {
    count = length(var.availability_zones)
    vpc = true
    tags = {
        Name = "nat-${count.index + 1}"
    }
  
}