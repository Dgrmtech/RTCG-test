# MODULES/Ecs/main.tf -- # ECS cluster and services configuration
# Responsabilities: Manages ECS cluster, task definitions, and services. Connects to ALB target group.

# modules/ecs/main.tf - ECS Module
# This module sets up the ECS cluster, task definitions, and services for deploying containerized applications.

# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name

  tags = {
    Name = var.cluster_name
  }
}

# ECS Task Definition
# Defines the task specification, including the container image, resource limits, and port mappings.
resource "aws_ecs_task_definition" "task" {
  family                   = var.cluster_name
  network_mode             = "awsvpc" # Required for Fargate
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # Adjust as per workload
  memory                   = "512" # Adjust as per workload
  execution_role_arn       = var.execution_role_arn # IAM role for ECR access
  task_role_arn            = var.task_role_arn # IAM role for application tasks

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.task_image
      cpu   = 256
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
    }
  ])

  tags = {
    Name = var.cluster_name
  }
}

# ECS Service
# Manages the deployment of tasks within the ECS cluster.
resource "aws_ecs_service" "service" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnets
    security_groups = var.security_groups
  }

  load_balancer {
    target_group_arn = var.alb_target_group
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags = {
    Name = "${var.cluster_name}-service"
  }
}
