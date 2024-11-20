resource "aws_ecr_repository" "model_repo" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "model_repo_policy" {
  repository = aws_ecr_repository.model_repo.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images after 30 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countNumber": 30,
        "countUnit": "days"
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}