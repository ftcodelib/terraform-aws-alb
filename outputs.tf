output "alb_this" {
  description = "ALB resouce output. Details can refer to https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#argument-reference"
  value       = aws_lb.this[0]
}