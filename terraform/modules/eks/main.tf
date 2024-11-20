# terraform/modules/eks/main.tf

module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  eks_managed_node_groups = {
    general = {
      desired_size = 2
      min_size     = 1
      max_size     = 5

      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"
    }

    gpu = {
      desired_size = 1
      min_size     = 0
      max_size     = 3

      instance_types = ["g4dn.xlarge"]
      capacity_type  = "ON_DEMAND"

      labels = {
        "accelerator" = "nvidia-tesla"
      }

      taints = [{
        key    = "nvidia.com/gpu"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
