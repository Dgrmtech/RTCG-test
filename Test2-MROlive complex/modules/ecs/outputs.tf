#

# Outputs for the ECS module
output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.cluster.id
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.task.arn
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.service.name
}
