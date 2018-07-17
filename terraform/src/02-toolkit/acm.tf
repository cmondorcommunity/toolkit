data "aws_acm_certificate" "main" {
  domain   = "${local.cert_hostname}"
  statuses = ["ISSUED"]
}

locals {
  cert_hostname = "${coalesce(var.cert_hostname_override, "${var.toolkit_hostname}.${var.domain}")}"
}

variable "cert_hostname_override" {
  default = ""
}
