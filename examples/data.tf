data "aws_route53_zone" "selected" {
  name         = var.dns_zone_name
  private_zone = false
}

data "aws_acm_certificate" "issued" {
  domain      = var.acm_certificate_domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "http" "get_external_ip" {
  url = "http://ipecho.net/plain"
}

locals {
  external_ip = format("%s/32", chomp(data.http.get_external_ip.body))
}