resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.app_name}"
  retention_in_days = local.log_retention_days

  tags = merge(local.tags, {
    Name = "${local.app_name}-logs"
  })
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for the application."
  value       = aws_cloudwatch_log_group.app.name
}
