# MODULES/Alb/main.tf -- ALB configuration
# Responsabilities: Sets up the Application Load Balancer, listener, and target groups. Outputs DNS name and ALB ARN.
# modules/alb/main.tf - ALB Module
# This module sets up the Application Load Balancer, listeners, target group, and security group.

# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "${var.name}-alb"
  internal           = false # Set to true for internal ALB
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  tags = {
    Name = "${var.name}-alb"
  }
}

# ALB Listener
# Listens for HTTP traffic on port 80 and forwards to the target group.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Target Group
# Routes traffic to ECS tasks.
resource "aws_lb_target_group" "target_group" {
  name        = "${var.name}-tg"
  port        = var.container_port # Matches ECS container port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # ECS Fargate uses IP target type

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
  }

  tags = {
    Name = "${var.name}-tg"
  }
}

# ALB Security Group
# Allows HTTP and HTTPS traffic to the ALB and outbound traffic to ECS tasks.
resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-sg"
  vpc_id      = var.vpc_id

  # Allow HTTP traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic from anywhere (if using HTTPS in the future)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-alb-sg"
  }
}





