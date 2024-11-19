terraform {
    backend "s3" {
        bucket = "terraform-states-mlops"
        key = "states/terraform.tfstate"
        region = "us-east-2"
        
    }
}