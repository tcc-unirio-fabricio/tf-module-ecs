resource "aws_ecs_task_definition" "app" {
  family                   = local.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.cpu
  memory                   = local.memory
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name      = local.app_name
    image     = local.container_image
    essential = true

    portMappings = [{
      containerPort = local.port
      hostPort      = local.port
      protocol      = "tcp"
    }]

    environment = [for name, value in local.container_environment : {
      name  = name
      value = value
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.app.name
        awslogs-region        = local.aws_region
        awslogs-stream-prefix = local.app_name
      }
    }

    mountPoints = local.enable_efs ? [{
      sourceVolume  = "app-data"
      containerPath = local.efs_container_path
      readOnly      = false
    }] : []
  }])

  dynamic "volume" {
    for_each = local.enable_efs ? [true] : []

    content {
      name = "app-data"

      efs_volume_configuration {
        file_system_id     = aws_efs_file_system.app[0].id
        root_directory     = "/"
        transit_encryption = "ENABLED"

        authorization_config {
          access_point_id = aws_efs_access_point.app[0].id
        }
      }
    }
  }

  tags = merge(local.tags, {
    Name = "${local.app_name}-task"
  })
}
