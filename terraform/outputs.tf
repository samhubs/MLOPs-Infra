# terraform/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "eks_cluster_id" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repository_url
}
