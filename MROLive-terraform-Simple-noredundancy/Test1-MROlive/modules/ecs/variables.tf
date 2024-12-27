#

variable "cluster_name" {
  description = "Name of the ECS cluster"
}

variable "vpc_id" {
  description = "VPC ID where ECS will be deployed"
}

variable "public_subnets" {
  description = "Public subnets for the ECS service"
  type        = list(string)
}

variable "task_image" {
  description = "Docker image for the ECS task"
}

variable "alb_target_group" {
  description = "ARN of the ALB target group"
}

variable "container_name" {
  description = "Name of the container"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "desired_count" {
  description = "Number of desired ECS tasks"
  type        = number
  default     = 1
}

variable "security_groups" {
  description = "Security groups for the ECS service"
  type        = list(string)
}