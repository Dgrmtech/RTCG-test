#

output "dns_name" {
  value = aws_lb.alb.dns_name
}

output "target_group_arn" {
  description = "The ARN of the ALB target group"
  value       = aws_lb_target_group.target_group.arn
}

