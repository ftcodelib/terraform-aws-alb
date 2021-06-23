#############################
# Application Load Balancer #
#############################
resource "aws_lb" "this" {
  count              = var.create ? 1 : 0
  name               = var.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  tags = var.tags
}

#########################
# ALB HTTP 443 LISTENER #
#########################
resource "aws_lb_listener" "https" {
  count             = var.create ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "503 - Not Found / ALB Forward Incorrectly"
      status_code  = "503"
    }
  }
}

########################
# ALB HTTP 80 LISTENER #
########################
resource "aws_lb_listener" "http" {
  count             = var.create ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

######################
# ALB Targets Config #
######################
resource "aws_lb_target_group" "this" {
  for_each = var.create ? { for item in var.hosts_config : item.name => item } : {}

  name                 = each.value.name
  port                 = each.value.port
  protocol             = each.value.target_type != "lambda" ? each.value.protocol : null
  vpc_id               = var.vpc_id
  target_type          = each.value.target_type
  deregistration_delay = each.value.deregistration_delay != null ? each.value.deregistration_delay : 300

  health_check {
    healthy_threshold   = each.value.healthy_threshold
    unhealthy_threshold = each.value.unhealthy_threshold
    timeout             = each.value.timeout
    interval            = each.value.interval
    path                = each.value.path != null ? each.value.path : null
    matcher             = each.value.matcher
  }

  tags = merge(
    var.tags, {
      Name = each.value.name
    }
  )
}

resource "aws_lb_listener_rule" "this_https" {
  for_each = var.create ? { for item in var.hosts_config : item.name => item } : {}

  listener_arn = aws_lb_listener.https[0].arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.name].arn
  }

  condition {
    host_header {
      values = ["${each.value.host_header}.${var.domain_name}"]
    }
  }
}

resource "aws_lb_target_group_attachment" "this_instances" {
  for_each = var.create ? { for item in var.hosts_config : item.name => item } : {}

  target_group_arn = aws_lb_target_group.this[each.value.name].arn
  target_id        = each.value.instances_id
  port             = each.value.port
}

#####################
# DNS Record Config #
#####################
resource "aws_route53_record" "this" {
  for_each = (var.create && var.create_dns_record) ? { for item in var.hosts_config : item.name => item } : {}

  zone_id = var.dns_zone_id
  name    = each.value.host_header
  type    = "CNAME"
  ttl     = var.dns_record_ttl
  records = [aws_lb.this[0].dns_name]

  depends_on = [aws_lb_target_group_attachment.this_instances]
}