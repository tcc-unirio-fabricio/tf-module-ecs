resource "aws_security_group" "app" {
  name        = "${local.app_name}-ecs-sg"
  description = "Allow application traffic from the load balancer"
  vpc_id      = local.vpc_id

  ingress {
    description     = "Application traffic from the load balancer"
    from_port       = local.port
    to_port         = local.port
    protocol        = "tcp"
    security_groups = [local.alb_security_group_id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.app_name}-ecs-sg"
  })
}

resource "aws_security_group" "efs" {
  count       = local.enable_efs ? 1 : 0
  name        = "${local.app_name}-efs-sg"
  description = "Allow NFS traffic from the ECS tasks"
  vpc_id      = local.vpc_id

  ingress {
    description     = "NFS from ECS tasks"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.app_name}-efs-sg"
  })
}
