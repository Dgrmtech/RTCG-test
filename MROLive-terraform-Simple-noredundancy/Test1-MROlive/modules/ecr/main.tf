# MODULES/Ecr/main.tf -- ECR repository configuration
# Responsabilities: Creates the ECR repository. Outputs repository URL.

resource "aws_ecr_repository" "repository" {
  name = var.repository_name
}

