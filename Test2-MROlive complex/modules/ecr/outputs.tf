

# Outputs for the ECR module
output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.repository.repository_url
}
