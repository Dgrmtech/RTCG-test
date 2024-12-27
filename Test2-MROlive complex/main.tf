# main.tf - Root Module
# This file integrates all submodules for the AWS infrastructure based on the "Diagram Final Version."

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1" # Adjust region as needed
  #profile = "default"   # Replace "default" with your AWS CLI profile name
}

# Network Module
# Creates the VPC, public and private subnets, NAT gateways, route tables, and VPC endpoints.
module "network" {
  source          = "./modules/network"
  name            = "mrolive-vpc"
  cidr            = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]
  region          = "us-east-1" # Pass the region here
}


# ALB Module
# Configures the Application Load Balancer, listener, and target group.
module "alb" {
  source          = "./modules/alb"
  vpc_id          = module.network.vpc_id
  subnets         = module.network.public_subnets
  security_groups = [module.network.alb_security_group_id]
  container_port  = 8000 # Port for ECS container
  name            = "mrolive-alb" # Add a name for the ALB resources
}



# ECR Module
# Sets up the Elastic Container Registry for Docker images.
module "ecr" {
  source                  = "./modules/ecr"
  repository_name         = "mrolive"
  cloudwatch_logs_endpoint = module.network.cloudwatch_logs_vpc_endpoint_id # Pass the correct endpoint
}


# ECS Module
# Manages the ECS cluster, task definition, and service.
module "ecs" {
  source                  = "./modules/ecs"
  cluster_name            = "mrolive-cluster"
  vpc_id                  = module.network.vpc_id
  private_subnets         = module.network.private_subnets
  task_image              = "${module.ecr.repository_url}:latest"
  alb_target_group        = module.alb.target_group_arn
  security_groups         = [module.network.ecs_security_group_id]
  #cloudwatch_logs_endpoint = module.network.cloudwatch_logs_vpc_endpoint_id

  # Required attributes
  container_port          = 8000 # Port where the container listens
  container_name          = "mrolive-app" # Name of the container
  execution_role_arn = "arn:aws:iam::123456789012:role/ecs-execution-role" # Replace with the valid role ARN
  task_role_arn      = "arn:aws:iam::123456789012:role/ecs-task-role" # Replace with the valid role ARN
}


# Outputs
# These outputs provide critical information about the deployed infrastructure.
output "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  value       = module.ecr.repository_url
}

output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.dns_name
}

output "vpc_id" {
  description = "VPC ID created by the network module"
  value       = module.network.vpc_id
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "public_subnets" {
  description = "Public subnets IDs"
  value       = module.network.public_subnets
}
