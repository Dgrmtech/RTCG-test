# MODULES/Ecr/main.tf -- ECR repository configuration
# Responsabilities: Creates the ECR repository. Outputs repository URL.
# modules/ecr/main.tf - ECR Module
# This module creates an Amazon Elastic Container Registry for storing Docker images.

# Create ECR Repository
resource "aws_ecr_repository" "repository" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE" # Allows updates to tags for existing images
  image_scanning_configuration {
    scan_on_push = true # Enables automated scanning for vulnerabilities on image push
  }

  tags = {
    Name = var.repository_name
  }
}

# Repository Lifecycle Policy
# Automatically manages image retention based on a lifecycle policy.
resource "aws_ecr_lifecycle_policy" "repository_policy" {
  repository = aws_ecr_repository.repository.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images older than 30 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
