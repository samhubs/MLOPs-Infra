# terraform/modules/ecr/outputs.tf

output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.model_repo.repository_url
}
