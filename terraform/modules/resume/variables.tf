variable "root_domain" {
  type    = string
  default = "aidandethlefs.com"
}

variable "subdomain" {
  type    = string
  default = "www.aidandethlefs.com"
}

variable "route53_zone_id" {
  type    = string
}

variable "region" {
  type    = string
}