resource "aws_alb_target_group" "test" {
  name     = "${var.ECS_CONTAINER_NAME}-albtg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.main.id}"

  health_check {
    interval            = 30
    path                = "/login"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb" "main" {
  name            = "tf-example-alb-ecs"
  subnets         = ["${data.aws_subnet.public_a.id}", "${data.aws_subnet.public_b.id}"]
  security_groups = ["${aws_security_group.lb_sg.id}"]
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.aws_acm_certificate.main.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.test.id}"
    type             = "forward"
  }
}

resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ELB"

  vpc_id = "${data.aws_vpc.main.id}"
  name   = "tf-ecs-lbsg"

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["${local.WAN_IP}/32"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
