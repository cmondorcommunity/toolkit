# workstation
data "external" "wan" {
  program = ["${path.cwd}/files/get_wanip.sh"]
}

locals {
  WAN_IP = "${coalesce(data.external.wan.result.ip, var.admin_cidr_ingress)}"
}

# VPC
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

data "aws_subnet" "public_a" {

  filter {
    name = "tag:Name"
    values = ["${var.environment}-${var.project}-${var.org}-public-us-west-2a"]
  }

}

data "aws_subnet" "public_b" {

  filter {
    name = "tag:Name"
    values = ["${var.environment}-${var.project}-${var.org}-public-us-west-2b"]
  }

}

data "aws_subnet" "private_a" {

  filter {
    name = "tag:Name"
    values = ["${var.environment}-${var.project}-${var.org}-private-us-west-2a"]
  }

}

data "aws_subnet" "private_b" {

  filter {
    name = "tag:Name"
    values = ["${var.environment}-${var.project}-${var.org}-private-us-west-2b"]
  }

}
