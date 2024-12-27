#
# Variables required for the ALB module
variable "name" {
  description = "Name prefix for ALB resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be deployed"
}

variable "subnets" {
  description = "Subnets where the ALB will be deployed"
  type        = list(string)
}

variable "security_groups" {
  description = "Security group IDs for the ALB"
  type        = list(string)
}

variable "container_port" {
  description = "Container port for the ECS service"
  type        = number
}
