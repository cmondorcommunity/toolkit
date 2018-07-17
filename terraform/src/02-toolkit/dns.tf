data "aws_route53_zone" "main" {
  name = "${var.domain}."
}

resource "aws_route53_record" "toolkit" {
  name    = "${var.toolkit_hostname}.${data.aws_route53_zone.main.name}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.main.id}"

  alias {
    name                   = "${aws_alb.main.dns_name}"
    zone_id                = "${aws_alb.main.zone_id}"
    evaluate_target_health = true
  }
}

variable "toolkit_hostname" {}
