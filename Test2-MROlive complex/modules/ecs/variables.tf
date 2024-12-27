#
# Variables required for the ECS module
variable "cluster_name" {
  description = "Name of the ECS cluster"
}

variable "task_image" {
  description = "ECR image for the container"
}

variable "container_name" {
  description = "Name of the container"
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
}

variable "execution_role_arn" {
  description = "IAM role for ECS task execution (e.g., ECR pull access)"
}

variable "task_role_arn" {
  description = "IAM role for the application running in ECS tasks"
}

variable "vpc_id" {
  description = "VPC ID where the ECS cluster resides"
}

variable "private_subnets" {
  description = "Private subnets where ECS tasks are deployed"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups associated with the ECS tasks"
  type        = list(string)
}

variable "alb_target_group" {
  description = "ARN of the target group for the Application Load Balancer"
}
