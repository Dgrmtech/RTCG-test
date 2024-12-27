
# Variables required for the ECR module
variable "repository_name" {
  description = "Name of the ECR repository"
}
variable "cloudwatch_logs_endpoint" {
  description = "VPC Endpoint for CloudWatch Logs"
}
