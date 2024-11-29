terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
    required_version = ">=1.2.0"
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "my_instance" {
    ami = "ami-0453ec754f44f9a4a"
    instance_type = "t2.micro"
    tags = {
        Name = "Demo-instance"
    }
}

