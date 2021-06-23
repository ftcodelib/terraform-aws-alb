<!-- BEGIN_TF_DOCS -->
# AWS ALB Module

This module to create AWS ALB form a set of list

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Examples

```hcl
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

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | ALB Name | `string` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | AWS SSL Certificate ARN | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | DNS domain name. Example: example.com | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security group ID's for the ALB | `list(string)` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of network IPV4 CIDR | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where to create security group | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to create this module | `bool` | `true` | no |
| <a name="input_create_dns_record"></a> [create\_dns\_record](#input\_create\_dns\_record) | Whether to create DNS record in AWS Route53 | `bool` | `true` | no |
| <a name="input_dns_record_ttl"></a> [dns\_record\_ttl](#input\_dns\_record\_ttl) | n/a | `number` | `300` | no |
| <a name="input_dns_zone_id"></a> [dns\_zone\_id](#input\_dns\_zone\_id) | AWS Route53 DNS Zone ID | `string` | `null` | no |
| <a name="input_hosts_config"></a> [hosts\_config](#input\_hosts\_config) | value | <pre>list(object({<br>    name                 = string<br>    port                 = string<br>    protocol             = string<br>    deregistration_delay = number<br>    healthy_threshold    = number<br>    unhealthy_threshold  = number<br>    timeout              = number<br>    interval             = number<br>    path                 = string<br>    matcher              = string<br>    host_header          = string<br>    target_type          = string<br>    instances_id         = string<br>  }))</pre> | `[]` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Whether its internal ALB. If External ALB, then leave it false. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tagging | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_this"></a> [alb\_this](#output\_alb\_this) | ALB resouce output. Details can refer to https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#argument-reference |

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.this_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
<!-- END_TF_DOCS -->    