resource "aws_efs_file_system" "ecs_efs" {
  creation_token = "${var.environment}-${var.project}-${var.org}-efs"
  encrypted      = true
  kms_key_id     = "${data.aws_kms_alias.ecs_efs.arn}"

  lifecycle {
    ignore_changes = ["kms_key_id"]
  }
}

data "aws_kms_alias" "ecs_efs" {
  name = "alias/aws/elasticfilesystem"
}

locals {
  subnets = ["${data.aws_subnet.private_a.id}", "${data.aws_subnet.private_b.id}"]
}

resource "aws_efs_mount_target" "ecs_efs_priva_mt" {
  count           = "${var.az_count}"
  file_system_id  = "${aws_efs_file_system.ecs_efs.id}"
  subnet_id       = "${element(local.subnets, count.index)}"
  security_groups = ["${aws_security_group.instance_sg.id}"]
}
