variable "hosted_zone_id" {
  description = "Hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "aws_lb_dns_name" {
  description = "Load balancer public DNS name"
  type        = string
}

variable "aws_lb_zone_id" {
  description = "Load balancer zone ID"
  type        = string
}
