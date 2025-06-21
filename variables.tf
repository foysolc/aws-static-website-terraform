variable "domain_name" {
  description = "foysol.cloud"
  type        = string
  default     = "foysol.cloud"
}

variable "subdomain_name" {
  description = "www.foysol.cloud"
  type        = string
  default     = "www"
}

variable "aws_region" {
  description = "eu-west-2"
  type        = string
  default     = "eu-west-2"
}

variable "acm_certificate_region" {
  description = "us-east-1"
  type        = string
  default     = "us-east-1"
}