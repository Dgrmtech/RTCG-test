#

# main.tf

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1" # Adjust region as needed
}

# Network Module
# This module creates the VPC, public and private subnets, and related networking resources.
module "network" {
  source = "./modules/network"

  name           = "mrolive-vpc"
  cidr           = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  azs            = ["us-east-1a", "us-east-1b"]
}

# ALB Module
# This module sets up the Application Load Balancer, listener, and target group.
module "alb" {
  source          = "./modules/alb"
  vpc_id          = module.network.vpc_id
  subnets         = module.network.public_subnets
  security_groups = [module.network.default_security_group_id]
}

# ECR Module
# This module creates an Amazon Elastic Container Registry to store Docker images.
module "ecr" {
  source = "./modules/ecr"

  repository_name = "mrolive"
}

# ECS Module
# This module sets up the ECS cluster, task definition, and service for deploying the application.
module "ecs" {
  source           = "./modules/ecs"
  cluster_name     = "mrolive-cluster"
  vpc_id           = module.network.vpc_id
  public_subnets   = module.network.public_subnets
  task_image       = "${module.ecr.repository_url}:latest"
  alb_target_group = module.alb.target_group_arn
  container_name   = "mrolive"
  container_port   = 8000
  security_groups  = [module.network.default_security_group_id]
}


# Outputs
# These outputs provide information about the resources created by the modules.
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
