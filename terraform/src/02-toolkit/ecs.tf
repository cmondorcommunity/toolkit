resource "aws_ecs_cluster" "main" {
  name = "${var.ECS_CONTAINER_NAME}"
}

data "template_file" "task_definition" {
  template = "${file("${path.module}/files/task-definition.json")}"

  vars {
    image_url          = "${var.ECS_IMAGE}"
    container_name     = "${var.ECS_CONTAINER_NAME}"
    log_group_region   = "${var.aws_region}"
    log_group_name     = "${aws_cloudwatch_log_group.app.name}"
    efs_volume_name    = "${var.ECS_VOLUME_NAME}"
    ecs_container_path = "${var.ECS_CONTAINER_PATH}"
  }
}

resource "aws_ecs_task_definition" "toolkit" {
  family                = "${var.ECS_CONTAINER_NAME}"
  container_definitions = "${data.template_file.task_definition.rendered}"
  execution_role_arn    = "${aws_iam_role.ecs_service.arn}"
  task_role_arn         = "${aws_iam_role.ecs_service.arn}"

  volume {
    name      = "${var.ECS_VOLUME_NAME}" #toolkit
    host_path = "${var.EFS_HOST_PATH}"   #/mnt/efs see coreos-cloud-config.yml
  }

  volume {
    name      = "docker_sock"
    host_path = "/var/run/docker.sock"
  }
}

resource "aws_ecs_service" "test" {
  name                               = "${var.ECS_CONTAINER_NAME}-service"
  cluster                            = "${aws_ecs_cluster.main.id}"
  task_definition                    = "${aws_ecs_task_definition.toolkit.arn}"
  desired_count                      = 1
  iam_role                           = "${aws_iam_role.ecs_service.arn}"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  health_check_grace_period_seconds  = 500

  load_balancer {
    target_group_arn = "${aws_alb_target_group.test.id}"
    container_name   = "${var.ECS_CONTAINER_NAME}"
    container_port   = "8080"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.front_end",
  ]
}
