#

variable "vpc_id" {
  description = "VPC ID where the ALB will be deployed"
}

variable "subnets" {
  description = "Subnets for the ALB"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups for the ALB"
  type        = list(string)
}
