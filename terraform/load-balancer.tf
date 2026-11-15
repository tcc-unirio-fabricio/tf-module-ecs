resource "aws_lb_target_group" "app" {
  name        = "${local.app_name}-tg"
  port        = local.port
  protocol    = local.protocol
  target_type = "ip"
  vpc_id      = local.vpc_id

  health_check {
    enabled             = true
    path                = local.health_check_path
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }

  tags = merge(local.tags, {
    Name = "${local.app_name}-tg"
  })
}

resource "aws_lb_listener_rule" "app" {
  listener_arn = local.alb_listener_arn
  priority     = local.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
