data "aws_vpc" "main" {
  filter {
    name = "tag:org"
    values = ["${var.org}"]
  }

  filter {
    name = "tag:environment"
    values = ["${var.environment}"]
  }

  filter {
    name = "tag:project"
    values = ["${var.project}"]
  }

}

data "aws_subnet" "main" {
  filter {
    name = "tag:org"
    values = ["${var.org}"]
  }

  filter {
    name = "tag:environment"
    values = ["${var.environment}"]
  }

  filter {
    name = "tag:project"
    values = ["${var.project}"]
  }

}
