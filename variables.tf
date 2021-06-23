variable "create" {
  description = "Whether to create this module"
  type        = bool
  default     = true
}

variable "alb_name" {
  description = "ALB Name"
  type        = string
}

variable "internal" {
  description = "Whether its internal ALB. If External ALB, then leave it false."
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "List of security group ID's for the ALB"
  type        = list(string)
}

variable "subnets" {
  description = "List of network IPV4 CIDR"
  type        = list(string)
}

variable "certificate_arn" {
  description = "AWS SSL Certificate ARN"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "domain_name" {
  description = "DNS domain name. Example: example.com"
  type        = string
}

variable "create_dns_record" {
  description = "Whether to create DNS record in AWS Route53"
  type        = bool
  default     = true
}

variable "dns_zone_id" {
  description = "AWS Route53 DNS Zone ID"
  type        = string
  default     = null
}

variable "dns_record_ttl" {
  default = 300
}

variable "hosts_config" {
  description = "value"
  type = list(object({
    name                 = string
    port                 = string
    protocol             = string
    deregistration_delay = number
    healthy_threshold    = number
    unhealthy_threshold  = number
    timeout              = number
    interval             = number
    path                 = string
    matcher              = string
    host_header          = string
    target_type          = string
    instances_id         = string
  }))

  default = []
}

variable "tags" {
  description = "Tagging"
  type        = map(any)
  default     = {}
}