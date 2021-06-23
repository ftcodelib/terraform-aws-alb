module "example_lb" {
  source = "../"

  alb_name        = "example-lb"
  internal        = false
  certificate_arn = data.aws_acm_certificate.issued.arn
  vpc_id          = data.aws_vpc.default.id
  subnets         = tolist(data.aws_subnet_ids.default.ids)
  security_groups = [module.lb_sg.this_security_group_id]
  domain_name     = data.aws_route53_zone.selected.name

  create_dns_record = true
  dns_zone_id       = data.aws_route53_zone.selected.zone_id
  dns_record_ttl    = 300

  depends_on = [module.lb_sg]
  tags       = var.tags

  hosts_config = [
    {
      name                 = "web-app-1"
      port                 = 80
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 300
      healthy_threshold    = 5
      unhealthy_threshold  = 2
      timeout              = 5
      interval             = 30
      path                 = "/"
      matcher              = "200,302"
      host_header          = "app1"
      instances_id         = aws_instance.web_server["server-1"].id
    },
    {
      name                 = "web-app-2"
      port                 = 80
      protocol             = "HTTP"
      target_type          = "ip"
      deregistration_delay = 300
      healthy_threshold    = 5
      unhealthy_threshold  = 2
      timeout              = 5
      interval             = 30
      path                 = null
      matcher              = "200,302"
      host_header          = "app2"
      instances_id         = aws_instance.web_server["server-2"].private_ip
    },
  ]
}
