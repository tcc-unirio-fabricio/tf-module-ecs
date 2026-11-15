resource "aws_lb_target_group" "app" {
  name        = "${local.app_name}-tg"
  port        = local.port
  protocol    = local.protocol
  target_type = "ip"
  vpc_id      = local.vpc_id

  health_check {
    enabled             = true
    path                = local.health_check_path
    matcher             = local.health_check_matcher
    healthy_threshold   = local.healthy_threshold
    unhealthy_threshold = local.unhealthy_threshold
    interval            = local.health_check_interval
    timeout             = local.health_check_timeout
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
