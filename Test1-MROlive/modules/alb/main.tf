# MODULES/Alb/main.tf -- ALB configuration
# Responsabilities: Sets up the Application Load Balancer, listener, and target groups. Outputs DNS name and ALB ARN.

resource "aws_lb" "alb" {
  name               = "mrolive-lb"
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets
}

resource "aws_lb_target_group" "target_group" {
  name     = "mrolive-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}



