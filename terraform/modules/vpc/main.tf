provider "aws" {
    region = var.aws_region
  
}
resource "aws_vpc" "mlops_terraform" {
  cidr_block = var.vpc_cidr
}

resource "aws_internet_gateway" "ig_mlops_terraform" {
  vpc_id = aws_vpc.mlops_terraform.id
}

resource "aws_subnet" "public" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.mlops_terraform.id
    cidr_block = var.public_subnet_cidrs[count.index]
    map_public_ip_on_launch = true

}

resource "aws_subnet" "private" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.mlops_terraform.id
    cidr_block = var.private_subnet_cidrs[count.index]

}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.mlops_terraform.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig_mlops_terraform.id
    }
  
}

resource "aws_route_table_association" "public" {
    count = length(var.availability_zones)
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
  
}

resource "aws_security_group" "mlops_sg" {
    name_prefix = "mlops-terraform-sg"
    vpc_id      = aws_vpc.mlops_terraform.id

    ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
    Name = "mlops-terraform-sg"
    }
}
