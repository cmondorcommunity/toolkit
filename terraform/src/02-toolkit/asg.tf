resource "aws_autoscaling_group" "app" {
  name                 = "tf-test-asg"
  vpc_zone_identifier  = ["${data.aws_subnet.private_a.id}", "${data.aws_subnet.private_b.id}"]
  min_size             = "${var.asg_min}"
  max_size             = "${var.asg_max}"
  desired_capacity     = "${var.asg_desired}"
  launch_configuration = "${aws_launch_configuration.app.name}"
}

data "template_file" "cloud_config_amznlinux" {
  template = "${file("${path.module}/files/ecs_user_data.sh.tpl")}"

  // wait for EFS before launching instances
  depends_on = ["aws_efs_mount_target.ecs_efs_priva_mt"]

  vars {
    aws_region         = "${var.aws_region}"
    ecs_cluster_name   = "${aws_ecs_cluster.main.name}"
    ecs_container_name = "${var.ECS_CONTAINER_NAME}"
    ecs_log_level      = "info"
    ecs_agent_version  = "latest"
    ecs_log_group_name = "${aws_cloudwatch_log_group.ecs.name}"
    efs_volume_id      = "${aws_efs_file_system.ecs_efs.id}"
    efs_local_path     = "${var.EFS_HOST_PATH}"
    efs_volume_name    = "${var.ECS_VOLUME_NAME}"
  }
}

resource "aws_launch_configuration" "app" {
  security_groups = [
    "${aws_security_group.instance_sg.id}",
  ]

  key_name                    = "${var.key_name}"
  image_id                    = "ami-decc7fa6"                                          #"${data.aws_ami.stable_coreos.id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.app.name}"
  user_data                   = "${data.template_file.cloud_config_amznlinux.rendered}"
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance_sg" {
  description = "controls direct access to application instances"
  vpc_id      = "${data.aws_vpc.main.id}"
  name        = "tf-ecs-instsg"

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = [
      "${local.WAN_IP}/32",
    ]
  }

  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0

    security_groups = [
      "${aws_security_group.lb_sg.id}",
    ]
  }

  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
