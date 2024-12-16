# MODULES/Ecs/main.tf -- # ECS cluster and services configuration
# Responsabilities: Manages ECS cluster, task definitions, and services. Connects to ALB target group.

# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = var.cluster_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.task_image
      cpu       = 256
      memory    = 512
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count

  launch_type = "FARGATE"

  network_configuration {
    subnets         = var.public_subnets
    security_groups = var.security_groups
  }

  load_balancer {
    target_group_arn = var.alb_target_group
    container_name   = var.container_name
    container_port   = var.container_port
  }
}

