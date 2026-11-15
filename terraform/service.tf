resource "aws_ecs_service" "app" {
  name                   = "${local.app_name}-service"
  cluster                = local.ecs_cluster_arn
  task_definition        = aws_ecs_task_definition.app.arn
  desired_count          = local.desired_count
  launch_type            = "FARGATE"
  platform_version       = "LATEST"
  force_new_deployment   = true
  enable_execute_command = false

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = local.subnet_ids
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = local.app_name
    container_port   = local.port
  }

  depends_on = [
    aws_lb_listener_rule.app,
    aws_efs_mount_target.app,
    aws_iam_role_policy_attachment.task_execution
  ]

  tags = merge(local.tags, {
    Name = "${local.app_name}-service"
  })
}

output "application_url" {
  description = "HTTP URL for the application."
  value       = "http://${local.alb_dns_name}"
}

output "ecs_service_arn" {
  description = "ARN of the ECS service."
  value       = aws_ecs_service.app.id
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition."
  value       = aws_ecs_task_definition.app.arn
}
