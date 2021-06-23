variable "dns_zone_name" {
  description = "The Hosted Zone name of the desired Hosted Zone."
  type        = string
}

variable "acm_certificate_domain_name" {
  description = "The domain of the certificate to look up."
  type        = string
}

variable "web_server_list" {
  description = "List of web server to be created"
  type        = list(string)
}