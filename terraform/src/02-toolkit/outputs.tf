output "instance_security_group" {
  value = "${aws_security_group.instance_sg.id}"
}

output "launch_configuration" {
  value = "${aws_launch_configuration.app.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.app.id}"
}

output "alb_hostname" {
  value = "${aws_alb.main.dns_name}"
}

output "toolkit_fqdn" {
  value = "${local.toolkit_fqdn}"
}

locals {
  toolkit_fqdn = "${aws_route53_record.toolkit.name}"
}
